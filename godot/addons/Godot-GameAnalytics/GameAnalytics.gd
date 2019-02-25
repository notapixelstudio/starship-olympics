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
const UUID = preload("uuid/uuid.gd")
const Utils = preload("utils.gd")

# device information
var DEBUG = true
var returned
var response_data
var response_code
var uuid = UUID.v4()

# if analytics are enabled
var enabled = false

# TODO: get from the dict
var platform = Utils.os_dict[OS.get_name()]
var os_version = Utils.os_dict[OS.get_name()] + " 10.14.3"
var sdk_version = 'rest api v2'
var device = OS.get_model_name()
var manufacturer = Utils.os_dict[OS.get_name()]

# game information
var build_version = '0.0.1'
var engine_version = 'Godot 3.1-beta3'

# sandbox game keys
var game_key = "5c6bcb5402204249437fb5a7a80a4959"
var secret_key = "16813a12f718bc5c620f56944e1abc3ea13ccbac"

# sandbox API urls
var base_url = "http://sandbox-api.gameanalytics.com"
var url_init = "/v2/" + game_key + "/init"
var url_events = "/v2/" + game_key + "/events"

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

func _ready():
	# generate session id
	generate_new_session_id()
	
# adding an event to the queue for later submit
func add_to_event_queue(event_dict: Dictionary):
	state_config['event_queue'].append(event_dict)

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
	url_init = "/v2/" + game_key + "/init"
	# var queryString = requests.query_string_from_dict(init_payload)
	# var init_payload_json = json.dumps(init_payload)
	var init_payload_json = to_json(init_payload)

	var headers = [
		"Authorization: " + Marshalls.raw_to_base64(hmac_sha256(init_payload_json, secret_key)),
		"Content-Type: application/json"
	]
	
	# response_dict = None
	# status_code = None
	var response_dict: Dictionary
	var status_code: int
	
	# debug purposes
	if DEBUG:
		print(base_url)
		print(url_init)
		print(init_payload_json)
		print(Marshalls.raw_to_base64(hmac_sha256(init_payload_json, secret_key)))
		
	# try/catch
	var err = requests.connect_to_host(base_url,80)
	
	if err:
		print("We could not connect. What should we do now?")

	# Wait until resolved and connected
	while requests.get_status() == HTTPClient.STATUS_CONNECTING or requests.get_status() == HTTPClient.STATUS_RESOLVING:
		requests.poll()
		print("Connecting..")
		OS.delay_msec(500)

	# Error catch: Could not connect
	assert(requests.get_status() == HTTPClient.STATUS_CONNECTED)
	
	var init_response : int = requests.request(HTTPClient.METHOD_POST, url_init, headers, init_payload_json)
	
	if init_response:
		print("Well, we could not connect here either")

	var text : String
	while requests.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling until the request is going on
		requests.poll()
		print("Requesting..")
		OS.delay_msec(500)
	
	if requests.has_response():
		# If there is a response..
		headers = requests.get_response_headers_as_dictionary() # Get response headers
		print("code: ", requests.get_response_code()) # Show response code
		print("**headers:\\n", headers) # Show headers

		# Getting the HTTP Body
		if requests.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = requests.get_response_body_length()
			print("Response Length: ", bl)

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
		print("bytes got: ", rb.size())
		text = rb.get_string_from_ascii()
		print("Text: ", text)
		
	status_code = requests.get_response_code()
	
	response_dict = parse_json(text)
	
	var response_string : String = str(status_code)

	if status_code == 401:
		post_to_log("Submit events failed due to UNAUTHORIZED.")
		post_to_log("Please verify your Authorization code is working correctly and that your are using valid game keys.")
		
	if status_code != 200:
		post_to_log("Init request did not return 200!")
		post_to_log(response_string)

	if 'enabled' in response_dict and response_dict['enabled']:
		print("We are enabled")
		state_config['enabled'] = true
	else:
		state_config['enabled'] = false
	
	# TODO: adjust ts ? 
	return status_code

# submitting all events that are in the queue to the events URL
func submit_events():
	if not enabled :
		print("Analytics not enabled")
		return
	#try:
	# Refreshing url_events since game key might have been changed externally
	url_events = "/v2/" + game_key + "/events"
	var event_list_json = to_json(state_config['event_queue'])
	print(event_list_json)

	# if gzip enabled
	if use_gzip:
		event_list_json = get_gzip_string(event_list_json)

	# create headers with authentication hash
	var headers = [
		"Authorization: " +  Marshalls.raw_to_base64(hmac_sha256(event_list_json, secret_key)),
		"Content-Type: application/json"]

	# if gzip enabled add the encoding header
	if use_gzip:
		headers['Content-Encoding'] = 'gzip'

	var err = requests.connect_to_host(base_url,80)

		# Wait until resolved and connected
	while requests.get_status() == HTTPClient.STATUS_CONNECTING or requests.get_status() == HTTPClient.STATUS_RESOLVING:
		requests.poll()
		print("Connecting..")
		OS.delay_msec(500)

	#try:
	var events_response = requests.request(HTTPClient.METHOD_POST, url_events, headers, event_list_json)
#    except Exception as e:
#        post_to_log("Submit events request failed!")
#        post_to_log(e.reason)
#        return (None, None)
	while requests.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling until the request is going on
		requests.poll()
		print("Requesting..")
		OS.delay_msec(500)
	
	if requests.has_response():
		# If there is a response..
		headers = requests.get_response_headers_as_dictionary() # Get response headers
		print("code: ", requests.get_response_code()) # Show response code
		print("**headers:\\n", headers) # Show headers

		# Getting the HTTP Body

		if requests.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = requests.get_response_body_length()
			print("Response Length: ",bl)

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

		print("bytes got: ", rb.size())
		var text = rb.get_string_from_ascii()
		print("Text: ", text)

	# var status_code = events_response.status_code
	var status_code = requests.get_response_code()
	# try:
	# var response_dict = events_response.json()
#    except:
#        response_dict = None

	# print_verbose("Submit events response: " + str(response_dict))

	# check response code
	#status_code_string = ("" if status_code is None else "Returned: " + str(status_code) + " response code.")
	var status_code_string = str(status_code)
	if status_code == 400:
		post_to_log(status_code_string)
		post_to_log("Submit events failed due to BAD_REQUEST.")

#        if isinstance(response_dict, (dict, list)):
#            post_to_log("Payload found in response. Contents can explain what fields are causing a problem.")
#            post_to_log(events_response.text)
#            sys.exit()
#    elif status_code == 401:
#        post_to_log(status_code_string)
#        post_to_log("Submit events failed due to UNAUTHORIZED.")
#        post_to_log("Please verify your Authorization code is working correctly and that your are using valid game keys.")

	elif status_code != 200:
		post_to_log(status_code_string)
		post_to_log("Submit events request did not succeed! Perhaps offline.. ")

	if status_code == 200:
		# clear event queue only if we have a status_code == true
		state_config['event_queue'] = []
		post_to_log("Events submitted !")
	else:
		post_to_log("Event submission FAILED!")

	return status_code


# ------------------ HELPER METHODS ---------------------- #


func generate_new_session_id():
	state_config['session_id'] = uuid
	print_verbose("Session Id: " + state_config['session_id'])


func update_client_ts_offset(server_ts):
	# calculate client_ts using offset from server time
	#datetime.utcnow()
	var now_ts = OS.get_unix_time_from_datetime(OS.get_datetime())
#    var client_ts = calendar.timegm(now_ts.timetuple())
	var client_ts = now_ts
	var offset = client_ts - server_ts
# --> Verificar
	#offset = 0

	# if too small difference then ignore
	if offset < 10:
		state_config['client_ts_offset'] = 0
	else:
		state_config['client_ts_offset'] = offset
	print_verbose('Client TS offset calculated to: ' + str(offset))


#func hmac_hash_with_secret(message, key):
#	#requests.
#    return utf8_to_base64(hmac.new(key, message, hashlib.sha256))


func get_test_business_event_dict():
	var event_dict = {
		'category': 'business',
		'amount': 999,
		'currency': 'USD',
		'event_id': 'Weapon:SwordOfFire',  # item_type:item_id
		'cart_type': 'MainMenuShop',
		'transaction_num': 1,  # should be incremented and stored in local db
		'receipt_info': {'receipt': 'xyz', 'store': 'apple'}  # receipt is base64 encoded receipt
	}
	return event_dict


func get_test_user_event():
	var event_dict = {
		'category': 'user'
	}
	merge_dir(event_dict, annotate_event_with_default_values())
	return event_dict


func get_test_session_end_event(length_in_seconds):
	var event_dict = {
		'category': 'session_end',
		'length': length_in_seconds
	}
	merge_dir(event_dict, annotate_event_with_default_values())
	return event_dict


func get_test_design_event(event_id, value):
	var event_dict = {
		'category': 'design',
		'event_id': event_id,
		'value': value
	}
	merge_dir(event_dict, annotate_event_with_default_values())
	return event_dict
	
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
#    var zip_text_file = StringIO()
#    var zipper = gzip.GzipFile('wb', zip_text_file)
#    zipper.write(string_for_gzip)
#    zipper.close()
#
#    enc_text = zip_text_file.getvalue()
#    return enc_text
	pass


# add default annotations (will alter the dict by reference)
#func annotate_event_with_default_values(event_dict):
func annotate_event_with_default_values():
	var now_ts = OS.get_datetime()
	# datetime.utcnow()
	# calculate client_ts using offset from server time
	#var client_ts = calendar.timegm(now_ts.timetuple()) - state_config['client_ts_offset']
	var client_ts = OS.get_unix_time_from_datetime(OS.get_datetime())

	# TEST IDFA / IDFV
	#var idfa = 'AEBE52E7-03EE-455A-B3C4-E57283966239'
	var idfa = OS.get_unique_id()
	var idfv = 'AEBE52E7-03EE-455A-B3C4-E57283966239'

	var default_annotations = {
		'v': 2,                                     # (required: Yes)
		'user_id': idfa,                            # (required: Yes)
		#'ios_idfa': idfa,                           # (required: No - required on iOS)
		#'ios_idfv': idfv,                           # (required: No - send if found)
		# 'google_aid'                              # (required: No - required on Android)
		# 'android_id',                             # (required: No - send if set)
		# 'googleplus_id',                          # (required: No - send if set)
		# 'facebook_id',                            # (required: No - send if set)
		# 'limit_ad_tracking',                      # (required: No - send if true)
		# 'logon_gamecenter',                       # (required: No - send if true)
		# 'logon_googleplay                         # (required: No - send if true)
		#'gender': 'male',                           # (required: No - send if set)
		# 'birth_year                               # (required: No - send if set)
		# 'progression                              # (required: No - send if a progression attempt is in progress)
		#'custom_01': 'ninja',                       # (required: No - send if set)
		# 'custom_02                                # (required: No - send if set)
		# 'custom_03                                # (required: No - send if set)
		'client_ts': client_ts,                     # (required: Yes)
		'sdk_version': sdk_version,                 # (required: Yes)
		'os_version': os_version,                   # (required: Yes)
		'manufacturer': manufacturer,                    # (required: Yes)
		'device': device,                      # (required: Yes - if not possible set "unknown")
		'platform': platform,                       # (required: Yes)
		'session_id': state_config['session_id'],   # (required: Yes)
		#'build': build_version,                     # (required: No - send if set)
		'session_num': 1,                           # (required: Yes)
		#'connection_type': 'wifi',                  # (required: No - send if available)
		# 'jailbroken                               # (required: No - send if true)
		#'engine_version': engine_version            # (required: No - send if set by an engine)
	}
	#event_dict.update(default_annotations)
	#state_config['event_queue'].append(default_annotations)
	return default_annotations

func print_verbose(message):
	print(message)
	if verbose_log:
		post_to_log(message)

func post_to_log(message):
	print(message)

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