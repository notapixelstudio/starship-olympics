extends Node

const LOG_PATH ="user://log.ndjson"
var file : FileAccess

func log_event(event: Dictionary, event_name:String, immediate: bool = true) -> void:
	#event.running_time = OS.get_ticks_usec()
	#event.datetime = datetime_to_str(OS.get_datetime(true))
	#event.local_datetime = datetime_to_str(OS.get_datetime())
	#event.execution_uuid = global.execution_uuid
	event.timestamp_local = Time.get_datetime_string_from_system(false, true)
	event.timestamp = Time.get_datetime_string_from_system(true, true)
	event.running_time = Time.get_ticks_usec()
	
	#file.store_line(JSON.new().stringify(event))
	#if immediate:
	#	file.flush() # WARNING writing to disk too often could hurt performance

func _init():
	# open the log file and go to the end
	var error = 0
	file = FileAccess.open(LOG_PATH, FileAccess.READ_WRITE)
	if file == null:
		print("We could not open a log file")
		print(FileAccess.get_open_error())
	else:
		var filesize_in_kb = file.get_length()/float(1024)
		print("Log file is {size} KB".format({"size":filesize_in_kb}))
		if filesize_in_kb > 200:
			file.close()
			print("Will remove the file because too big")
			error = DirAccess.remove_absolute(LOG_PATH)
			error = ERR_FILE_NOT_FOUND
		if error == ERR_FILE_NOT_FOUND :
			error = FileAccess.open(LOG_PATH, FileAccess.WRITE_READ)
		if error == OK:
			file.seek_end()
		else:
			print("We could not open a log file")
	
	# events connected and logged
	Events.connect('analytics_event', Callable(self, 'log_event'))
	
