extends Node
# GameAnalytics <https://gameanalytics.com/> native GDScript REST API implementation
# Cross-platform. Should work in every platform supported by Godot
# Adapted from REST_v2_example.py by Cristiano Reis Monteiro <cristianomonteiro@gmail.com> Abr/2018

""" 
https://restapidocs.gameanalytics.com
Procedure:
	1. make an init call
		- check if game is disabled
		- calculate client timestamp offset from server time
	2. start a session
	3. add a user event (session start) to queue
	4. add a business event + some design events to queue
	5. submit events in queue
	6. add some design events to queue
	7. add session_end event to queue
	8. submit events in queue
"""
# From https://github.com/xsellier/godot-uuid
const Utils = preload("utils.gd") 
const THRESHOLD_DIFF_TS = 10
const MAX_RETRY = 5
const WAIT_TIME = 0.3

# device information
var DEBUG = false
var returned
var uuid = UUID.v4()

# if analytics are enabled
var enabled = false setget _set_analytics

func _set_analytics(value: bool):
	enabled = value
	# SET game analytics parameters for the game
	base_url = ProjectSettings.get_setting("Analytics/base_url")
	game_key = ProjectSettings.get_setting("Analytics/game_key")
	secret_key = ProjectSettings.get_setting("Analytics/secret_key")
	
	print_debug("Analytics enabled? " + str(enabled))
	if enabled:
		request_init()
		add_event("user")
	else:
		end_session()

# TODO: get from the dict
var platform = Utils.os_dict[OS.get_name()]

# white space to get the pattern for the OS version
var os_version = Utils.os_dict[OS.get_name()] + " " 
var sdk_version = 'rest api v2'
var device = OS.get_model_name()
var manufacturer = Utils.os_dict[OS.get_name()]

# game information
var build_version = '0.6.0'
var engine_version = "Godot " + Engine.get_version_info()["string"]

# sandbox game keys
var game_key 
var secret_key 

# sandbox API urls
var base_url = "http://sandbox-api.gameanalytics.com"


# settings
var use_gzip = false
var verbose_log = false

# global state to track changes when code is running
var state_config = {
	# the amount of seconds the client time is offset by server_time
	# will be set when init call receives server_time
	'client_ts_offset': 0,
	# will be updated when a new session is started
	'session_id': uuid,
	# set if SDK is disabled or not - default enabled
	'enabled': true,
	# event queue - contains a list of event dictionaries to be JSON encoded
	'event_queue': []
}
var requests = HTTPClient.new()
# var http_request = HTTPRequest.new()

signal message_sent
signal response_ready

func _ready():
	# generate session id
	generate_new_session_id()
	
	# Connect to global
	
	if enabled:
		request_init()
		get_user_event()
		submit_events()
	# END Game Analytics
	
# adding an event to the queue for later submit
func add_to_event_queue(event_dict: Dictionary):
	state_config['event_queue'].append(event_dict)

func get_event_queue():
	return state_config['event_queue']

func reset_event_queue():
	state_config['event_queue'] = []

func send_data(endpoint:String, data_json:String, port:int = 80)-> Dictionary:
	# return dictionary : e.g.: {"status": 200, "response": {}}
	
	var url_endpoint = "/v2/"+self.game_key+"/"+endpoint
	
	# if gzip enabled
	if self.use_gzip:
		data_json = get_gzip_string(data_json)

	var headers = [
		"Authorization: " + Marshalls.raw_to_base64(hmac_sha256(data_json, self.secret_key)),
		"Content-Type: application/json"
	]

	# if gzip enabled add the encoding header
	if self.use_gzip:
		headers['Content-Encoding'] = 'gzip'
	
	# debug purposes
	if DEBUG:
		print_debug(base_url)
		print_debug(url_endpoint)
		print_debug(data_json)
		print_debug(Marshalls.raw_to_base64(hmac_sha256(data_json, secret_key)))

	var response_dict: Dictionary
	var status_code: int
		
	var err = requests.connect_to_host(self.base_url,80)
	
	if err:
		print_debug("We could not connect. What should we do now?")
		print(err)

	# Wait until resolved and/or connected
	for i in range(MAX_RETRY):
	# while requests.get_status() == HTTPClient.STATUS_CONNECTING or requests.get_status() == HTTPClient.STATUS_RESOLVING:
		requests.poll()
		if requests.get_status() == HTTPClient.STATUS_CONNECTED:
			print("Connected to ", base_url)
			break
		# let's wait one second before retrying
		yield(get_tree().create_timer(WAIT_TIME), "timeout")
		
	
	var response_code = requests.request(HTTPClient.METHOD_POST, url_endpoint, headers, data_json)

	var response_string : String # will contain the response
	var count = 0
	for i in range(MAX_RETRY):
		# while requests.get_status() == HTTPClient.STATUS_CONNECTING or requests.get_status() == HTTPClient.STATUS_RESOLVING:
		requests.poll()
		if requests.get_status() == HTTPClient.STATUS_BODY:
			break
		# let's wait one second before retrying
		yield(get_tree().create_timer(WAIT_TIME), "timeout")
		count = i
		
	print("Waited {wait_time}s".format({"wait_time": float(WAIT_TIME * count)}))
	
	if requests.has_response():
		# If there is a response..
		headers = requests.get_response_headers_as_dictionary() # Get response headers
		
		if DEBUG:
			print_debug("code: ", requests.get_response_code()) # Show response code
			print_debug("**headers: ", headers) # Show headers

		# Getting the HTTP Body
		if requests.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = requests.get_response_body_length()
			# print_debug("Response Length: ", bl)

		# This method works for both anyway
		var rb = PoolByteArray() # Array that will hold the data
		
		while requests.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			requests.poll()
			var chunk = requests.read_response_body_chunk() # Get a chunk
			if chunk.size() == 0:
				# Got nothing, wait for buffers to fill a bit
				OS.delay_usec(1000)
			else:
				rb = rb + chunk # Append to read buffer

		# Done!
		response_string = rb.get_string_from_ascii()
		
		
	status_code = requests.get_response_code()

	match status_code:
		401:
			print("ERROR: Submit events failed due to UNAUTHORIZED.")
			print("ERROR: Please verify your Authorization code is working correctly and that your are using valid game keys.")
			state_config['enabled'] = false
			enabled = false
			return status_code
			
		200:
			print("Response received correctly")
			reset_event_queue()
		_:
			print("Request did not return 200!")
			print(response_string)
	
	emit_signal("message_sent")
	
	if endpoint == "init":
		if response_string:
			response_dict = parse_json(response_string)
	
		if 'enabled' in response_dict and response_dict['enabled']:
			state_config['enabled'] = true
		else:
			state_config['enabled'] = false
	
	# TODO: adjust ts ? 
	# TODO: We should return if enabled or not
	# TODO: This should be syncronous
	return status_code

# requesting init URL and returning result
func request_init():
	if not enabled:
		return
	
	var init_payload = {
		'platform': platform,
		'os_version': os_version,
		'sdk_version': sdk_version
	}
	
	# Refreshing url_init since game key might have been changed externally
	send_data("init", to_json(init_payload))
	
	return 
	
# submitting all events that are in the queue to the events URL
func submit_events():

	# Refreshing url_events since game key might have been changed externally
	if not enabled :
		return
	
	var event_list_json = to_json(state_config['event_queue'])
	send_data("events", event_list_json)



func add_event(category, events: Dictionary = {}) -> Dictionary:
	var event_dict = {}
	match category:
		"user":
			event_dict = get_user_event()
		"session_end":
			event_dict = get_session_end_event()
		"business":
			event_dict = get_business_event_dict(events.amount, events.currency, events.event_id, events.transaction_num)
		"resource":
			pass
		"progression":
			pass
		"design":
			event_dict = get_design_event(events.event_id, events.get("value", -1))
		"error":
			pass
		"_":
			print("{} Not available".format(category))	
	
	add_to_event_queue(event_dict)
	if len(get_event_queue()) >= 5:
		submit_events()
	
	return event_dict

# ------------------ HELPER METHODS ---------------------- #

func generate_new_session_id():
	state_config['session_id'] = uuid

func update_client_ts_offset(server_ts):
	# calculate client_ts using offset from server time
	var now_ts = OS.get_unix_time_from_datetime(OS.get_datetime())
	var client_ts = now_ts
	var offset = client_ts - server_ts

	# if too small difference then ignore
	if offset < THRESHOLD_DIFF_TS:
		state_config['client_ts_offset'] = 0
	else:
		state_config['client_ts_offset'] = offset

static func merge_dir(target, patch):
	for key in patch:
		target[key] = patch[key]

static func merge_dir2(target, patch):
	for key in patch:
		if target.has(key):
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				merge_dir(tv, patch[key])
			else:
				target[key] = patch[key]
		else:
			target[key] = patch[key]

func get_gzip_string(string_for_gzip):
	# ZIP function
	pass

# ------------------ EXAMPLE METHODS ---------------------- #
func get_business_event_dict(amount, currency, event_id, transaction_num, cart_type = null, receipt_info = null ):
	# https://restapidocs.gameanalytics.com/#business
	var event_dict = {
		'category': 'business',
		'amount': 999,
		'currency': 'USD',
		'event_id': 'Weapon:SwordOfFire',  # item_type:item_id
		'cart_type': 'MainMenuShop',
		'transaction_num': 1,  # should be incremented and stored in local db
		'receipt_info': {'receipt': 'xyz', 'store': 'apple'}  # receipt is base64 encoded receipt
	}
	merge_dir(event_dict, annotate_event_with_default_values())
	return event_dict


func get_user_event():
	var event_dict = {
		'category': 'user'
	}
	merge_dir(event_dict, annotate_event_with_default_values())
	return event_dict

func end_session():
	
	add_event("session_end")
	submit_events()

func get_session_end_event():
	var length_in_seconds = min(OS.get_ticks_msec()/1000, 172800)
	var event_dict = {
		'category': 'session_end',
		'length': length_in_seconds
	}
	merge_dir(event_dict, annotate_event_with_default_values())
	return event_dict

func get_design_event(event_id, value):
	var event_dict = {
		'category': 'design',
		'event_id': event_id,
		'value': value
	}
	merge_dir(event_dict, annotate_event_with_default_values())
	return event_dict
	
func annotate_event_with_default_values():
	# add default annotations (will alter the dict by reference)
	# func annotate_event_with_default_values(event_dict):
	var now_ts = OS.get_datetime()
	
	# calculate client_ts using offset from server time
	var client_ts = OS.get_unix_time_from_datetime(OS.get_datetime())

	# TEST IDFA / IDFV
	var idfa = OS.get_unique_id()
	var idfv = 'AEBE52E7-03EE-455A-B3C4-E57283966239' # placeholder

	var default_annotations = {
		'v': 2,										# (required: Yes)
		'user_id': idfa,                            # (required: Yes)
		# 'ios_idfa': idfa,                         # (required: No - required on iOS)
		# 'ios_idfv': idfv,                         # (required: No - send if found)
		# 'google_aid'                              # (required: No - required on Android)
		# 'android_id',                             # (required: No - send if set)
		# 'googleplus_id',                          # (required: No - send if set)
		# 'facebook_id',                            # (required: No - send if set)
		# 'limit_ad_tracking',                      # (required: No - send if true)
		# 'logon_gamecenter',                       # (required: No - send if true)
		# 'logon_googleplay                         # (required: No - send if true)
		# 'gender': 'male',                         # (required: No - send if set)
		# 'birth_year                               # (required: No - send if set)
		# 'progression                              # (required: No - send if a progression attempt is in progress)
		#'custom_01': 'ninja',                      # (required: No - send if set)
		# 'custom_02                                # (required: No - send if set)
		# 'custom_03                                # (required: No - send if set)
		'client_ts': client_ts,                     # (required: Yes)
		'sdk_version': sdk_version,                 # (required: Yes)
		'os_version': os_version,                   # (required: Yes)
		'manufacturer': manufacturer,               # (required: Yes)
		'device': device,                      		# (required: Yes - if not possible set "unknown")
		'platform': platform,                       # (required: Yes)
		'session_id': state_config['session_id'],   # (required: Yes)
		#'build': build_version,                    # (required: No - send if set)
		'session_num': 1,                           # (required: Yes)
		#'connection_type': 'wifi',                 # (required: No - send if available)
		# 'jailbroken                               # (required: No - send if true)
		#'engine_version': engine_version           # (required: No - send if set by an engine)
	}
	return default_annotations

func hmac_sha256(message, key):
	var x = 0
	var k
	
	if key.length() <= 64:
		k = key.to_utf8()

	# Hash key if length > 64
	if key.length() > 64:
		k =  key.sha256_buffer()

	# Right zero padding if key length < 64
	while k.size() < 64:
		k.append(convert_hex_to_dec("00"))

	var i = "".to_utf8()
	var o = "".to_utf8()
	var m = message.to_utf8()
	var s = File.new()
			
	while x < 64:
		o.append(k[x] ^ 0x5c)
		i.append(k[x] ^ 0x36)
		x += 1
		
	var inner = i + m
	
	s.open("user://temp", File.WRITE)
	s.store_buffer(inner)
	s.close()
	var z = s.get_sha256("user://temp")
	
	var outer = "".to_utf8()
	
	x = 0
	while x < 64:
		outer.append(convert_hex_to_dec(z.substr(x, 2)))
		x += 2
	
	outer = o + outer
	
	s.open("user://temp", File.WRITE)
	s.store_buffer(outer)
	s.close()
	
	z = s.get_sha256("user://temp")
	
	outer = "".to_utf8()
	
	x = 0
	while x < 64:
		outer.append(convert_hex_to_dec(z.substr(x, 2)))
		x += 2
	
	var mm = outer
	return outer
	
func convert_hex_to_dec(h):
	var c = "0123456789ABCDEF"
	
	h = h.to_upper()
	
	var r = h.right(1)
	var l = h.left(1)
	
	var b0 = c.find(r)
	var b1 = c.find(l) * 16
	
	var x = b1 + b0
	return x
