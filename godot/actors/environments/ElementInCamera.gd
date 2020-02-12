extends Position2D

signal completed

func _ready():
	deactivate()
	
func move(new_position: Vector2, wait_time: float):
	$Tween.interpolate_property(self, "position", position, new_position, wait_time, Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	emit_signal("completed")

func deactivate():
	if is_in_group("in_camera"):
		remove_from_group("in_camera")
	
func activate():
	if not is_in_group("in_camera"):
		add_to_group("in_camera")
