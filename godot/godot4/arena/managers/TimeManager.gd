extends Node

var _time := 0.0
var _time_secs := 0

func set_time(v: float) -> void:
	_time = v

func _physics_process(delta: float) -> void:
	_time -= delta
	var new_time_secs = int(_time)
	if new_time_secs != _time_secs:
		_time_secs = new_time_secs
		Events.clock_ticked.emit(_time, _time_secs)
		
	if _time <= 0:
		Events.clock_ticked.emit(0.0, 0)
		
