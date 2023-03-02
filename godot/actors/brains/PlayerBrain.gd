extends Brain

var controls: String setget set_controls

func set_controls(v: String) -> void:
	controls = v

func local_handling() -> Vector2:
	var target = Vector2()
	
	if controllee.has_method("are_controls_enabled") and controllee.are_controls_enabled():
		target.x = Input.get_action_strength(controls+"_right") - Input.get_action_strength(controls+"_left")
		target.y = Input.get_action_strength(controls+"_down") - Input.get_action_strength(controls+"_up")
		
	return target

func tick():
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
	
	if controllee.has_method('is_auto_thrust') and controllee.is_auto_thrust():
		if target_velocity.length() <= 0.1:
			target_velocity = front
		else:
			# always at maximum, no fine control
			target_velocity = target_velocity.normalized()
			
	#rotation_request = find_side(Vector2(0,0), front, target_velocity)
	if target_velocity.length() <= 0.1: # vector deadzone
		rotation_request = 0
	else:
		# maximum speed (prevents moving faster in diagonal, and mitigates differences between controller models)
		target_velocity = 1.3*target_velocity.normalized()*min(1.0, target_velocity.length())
		rotation_request = front.angle_to(target_velocity)
		
	# if we want tank mode control (relative control)
	# rotation_request = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))

func _unhandled_input(event):
	if controllee.has_method("are_controls_enabled") and controllee.are_controls_enabled() and event.is_action_pressed(controls+'_fire'):
		emit_signal('charge')
	
	# release is possible even if controls are not enabled
	if event.is_action_released(controls+'_fire'):
		emit_signal('release')
