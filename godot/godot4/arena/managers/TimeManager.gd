extends Node

var _time := 0.0
var _time_secs := 0

func _ready():
	Events.match_over.connect(_on_match_over)

func set_time(v: float) -> void:
	_time = v

func _physics_process(delta: float) -> void:
	_time -= delta
	var new_time_secs = ceil(_time)
	if new_time_secs != _time_secs:
		_time_secs = new_time_secs
		Events.clock_ticked.emit(_time, _time_secs)
		
	if _time <= 0:
		Events.clock_ticked.emit(0.0, 0)
		Events.clock_expired.emit()
		
func _on_match_over() -> void:
	set_physics_process(false)
