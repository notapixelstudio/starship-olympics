extends Node

var start_time = 0
var this_elapsed_time = 0
# Create an HTTP request node and connect its completion signal.
# will change this in case 
onready var api_hostname = ProjectSettings.get_setting("Analytics/Hostname.debug") if OS.is_debug_build() else ProjectSettings.get_setting("Analytics/Hostname")
onready var token = "Godotexport_v1.0.0"

const ENDPOINT="messages"

func _ready():
	api_hostname = ProjectSettings.get_setting("Analytics/Hostname.debug") if OS.is_debug_build() else ProjectSettings.get_setting("Analytics/Hostname")
	return 
	
func send_event(event_body: Dictionary, event_name: String):
	event_body.timestamp = Time.get_datetime_string_from_system(true, true)
	event_body.event_name = event_name
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	var headers = [
		"Authorization: Basic " + Marshalls.utf8_to_base64(token),
		"Content-Type: application/json"
	]
	var error = http_request.request(api_hostname + "/" + ENDPOINT, headers, true, HTTPClient.METHOD_POST, to_json(event_body))
	if error != OK:
		push_error("An error occurred in the HTTP request. {error}".format({"error": error}) )

func add_timestamp():
	return  Time.get_datetime_string_from_system(true, true)
	


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	print(result)
	print(response_code)
	print(headers)
	print(body)
	var response = parse_json(body.get_string_from_utf8())

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	print(response)

func _process(_delta):
	this_elapsed_time = format_time(OS.get_ticks_msec() - start_time)

func start_elapsed_time():
	start_time = OS.get_ticks_msec()

func format_time(elapsed):
	var seconds = float(elapsed) / 1000
	var minutes = seconds / 60
	return "%02.3f" % [seconds]
	#return "%02d:%02.3f" % [minutes, seconds]

func end_run(start, end):
	return format_time(end - start)
