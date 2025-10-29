extends Node

var _time := 0.0
var _time_secs := 0

func _ready():
	set_physics_process(false)
	Events.match_over.connect(_on_match_over)
	
func start():
	set_physics_process(true)
	
func stop():
	set_physics_process(false)

func set_time(v: float) -> void:
	_time = v

func get_remaining_time() -> float:
	return _time

func _physics_process(delta: float) -> void:
	_time -= delta
	var new_time_secs = ceil(_time)
	if new_time_secs != _time_secs:
		_time_secs = new_time_secs
		Events.clock_ticked.emit(_time, _time_secs)
		
	if _time <= 0:
		Events.clock_ticked.emit(0.0, 0)
		Events.clock_expired.emit()
		
func _on_match_over(data: Dictionary) -> void:
	set_physics_process(false)
