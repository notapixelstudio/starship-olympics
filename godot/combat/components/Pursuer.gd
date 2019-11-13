extends Component

var target : Ship setget set_target, get_target

export var keep_target_timeout : float = 1.0
export var detection_insensitive_timeout : float = 1.0
var keep_target_t : float = 0
var detection_insensitive_t : float = 0

func set_target(value):
	target = value
	
func get_target():
	return target
	
func set_keep_target_timeout():
	keep_target_t = keep_target_timeout
	
func set_detection_insensitive_timeout():
	detection_insensitive_t = detection_insensitive_timeout
	
func update_timeouts(delta):
	if not enabled:
		return
		
	keep_target_t -= delta
	detection_insensitive_t -= delta
	
func has_keep_target_timed_out():
	return keep_target_t <= 0
	
func has_detection_insensitive_timed_out():
	return detection_insensitive_t <= 0
	