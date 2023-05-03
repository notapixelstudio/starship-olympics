extends Node

var start_time = 0
var this_elapsed_time = 0
# Create an HTTP request node and connect its completion signal.


func _ready():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	# Perform a GET request. The URL below returns JSON as of writing.
	#var error = http_request.request("https://httpbin.org/get")
	#if error != OK:
	#	push_error("An error occurred in the HTTP request.")
	# Perform a POST request. The URL below returns JSON as of writing.
	# Note: Don't make simultaneous requests using a single HTTPRequest node.
	# The snippet below is provided for reference only.
	var headers = [
		"Authorization: Basic " + Marshalls.utf8_to_base64("elastic:W+jN3=-7F7fMKaRHWCnZ"),
		"Content-Type: application/json"
	]
	var body = to_json({"name": "Godette"})
	var error = http_request.request("https://localhost:9200/_cat/indices", headers, true, HTTPClient.METHOD_GET, body)
	if error != OK:
		push_error("An error occurred in the HTTP request. {error}".format({"error": error}) )


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
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
