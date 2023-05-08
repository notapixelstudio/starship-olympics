extends Node

# Global variables
var start_time = 0
var this_elapsed_time = 0
onready var api_hostname = ProjectSettings.get_setting("Analytics/hostname.debug") if OS.is_debug_build() else ProjectSettings.get_setting("Analytics/hostname")
onready var token = "Godotexport_v1.0.0"
const ENDPOINT = "messages"

func _ready():
	"""Called when the node is added to the scene."""
	# events connected and logged
	Events.connect("analytics_event", self, '_on_analytics_event')

	return

func send_event(event_body: Dictionary, event_name: String):
	"""Sends an HTTP request with the given event body and name."""
	# Add timestamp, event name, and version to the event body
	event_body.timestamp = add_timestamp()
	event_body.event_name = event_name
	event_body.version = global.version
	event_body.debug_mode = OS.is_debug_build()
	event_body.installation_id = global.installation_id
	
	# Create a new HTTP request node and connect its completion signal
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed", [http_request])
	
	# Set request headers and send the request
	var headers = [
		"Authorization: Basic " + Marshalls.utf8_to_base64(token),
		"Content-Type: application/json"
	]
	var error = http_request.request(api_hostname + "/" + ENDPOINT, headers, true, HTTPClient.METHOD_POST, to_json(event_body))
	if error != OK:
		push_error("An error occurred in the HTTP request. {error}".format({"error": error}) )

func add_timestamp() -> String:
	"""Returns the current date and time as a formatted string."""
	return Time.get_datetime_string_from_system(true, true)

func _http_request_completed(result, response_code, headers, body, http_request):
	"""Called when the HTTP request is completed."""
	print("Request completed! Result code: %s" % [result])    
	print(response_code)
	print(headers)
	
	# Handle errors and parse response body
	var error = "NA"
	if result == ERR_UNAVAILABLE:
		error = "Request endpoint not available"
	if body:
		print(parse_json(body.get_string_from_utf8()))
	else:
		push_error("An error occurred in the HTTP request to {api_endpoint}. {error}".format({"error": error, "api_endpoint": api_hostname}) )
	
	# Free the HTTP request node
	http_request.queue_free()

func _process(_delta):
	"""Called every frame."""
	this_elapsed_time = format_time(OS.get_ticks_msec() - start_time)

func start_elapsed_time():
	"""Starts measuring elapsed time."""
	start_time = OS.get_ticks_msec()

func format_time(elapsed) -> String:
	"""Formats the given elapsed time as a string."""
	var seconds = float(elapsed) / 1000
	return "%02.3f" % [seconds]

func end_run(start, end) -> String:
	"""Returns the elapsed time between the start and end times as a string."""
	return format_time(end - start)

func _on_analytics_event(event_body: Dictionary, event_name: String):
	send_event(event_body, event_name)

