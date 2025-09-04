extends Brain
class_name PlayerBrain

var _controls: PackedStringArray

var action_buffer : Dictionary = {}

func set_controls(v: String) -> void:
	_controls = v.split('+')
	
func _ready():
	controllee.connect('dive_out', Callable(self, '_on_controllee_dive_out'))
	
func local_handling() -> Vector2:
	var target = Vector2()
	
	if controllee.has_method("are_controls_enabled") and controllee.are_controls_enabled():
		for control in _controls: # support multiple controls at once
			target.x += Input.get_action_strength(control+"_right") - Input.get_action_strength(control+"_left")
			target.y += Input.get_action_strength(control+"_down") - Input.get_action_strength(control+"_up")
		
	return target

func _physics_process(delta):
	tick()
	if controllee.has_method("set_target_velocity"):
		controllee.set_target_velocity(target_velocity)
	if controllee.has_method("set_rotation_request"):
		controllee.set_rotation_request(rotation_request)
	
func tick():
	if not enabled:
		return
		
	#var target_vel = Vector2()
	var front = Vector2(cos(global_rotation), sin(global_rotation))
	#target_vel = local_handling()
	
	#if target_vel == Vector2.ZERO:
	#	target_velocity = front
	#	# this in order to keep the velocity constant
	#	pass
	#else:
	#	target_velocity = target_vel.normalized()
	target_velocity = local_handling()
	
	#rotation_request = find_side(Vector2(0,0), front, target_velocity)
	if target_velocity.length() <= 0.1: # vector deadzone
		rotation_request = 0
	else:
		# maximum speed (prevents moving faster in diagonal, and mitigates differences between controller models)
		target_velocity = 1.3*target_velocity.normalized()*min(1.0, target_velocity.length())
		rotation_request = front.angle_to(target_velocity)
		
	# if we want tank mode control (relative control)
	# rotation_request = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))
	
func buffer_action(action_name: String) -> void:
	action_buffer[action_name] = Time.get_ticks_msec()
	
func is_action_buffered(action_name: String, since_msec: int) -> bool:
	return action_buffer.has(action_name) and Time.get_ticks_msec() - action_buffer[action_name] <= since_msec
 
func _unhandled_input(event):
	if not enabled:
		return
		
	for control in _controls:
		# charge and release even if controls are disabled
		if event.is_action_pressed(control+'_fire'):
			buffer_action('charge')
			controllee.charge()
		elif event.is_action_released(control+'_fire'):
			buffer_action('release')
			controllee.release()

# replay charge input if diving out and it was buffered
func _on_controllee_dive_out():
	if is_action_buffered('charge', 300):
		emit_signal('charge')
	
