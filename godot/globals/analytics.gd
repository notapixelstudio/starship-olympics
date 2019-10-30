extends Node

var start_time = 0
var this_elapsed_time = 0

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
