extends ColorRect
const SPEED = 100
const SPEED_DECREASE = 700
var time = 0
signal completed

func _process(delta):
	if Input.is_action_pressed("kb1_fire"):
		time += (delta*SPEED)
	else:
		time = max(0, time - delta*SPEED_DECREASE)
	self.material.set_shader_param("value", time)
	if time >= 100.0:
		set_process_input(false)
		emit_signal("completed")
