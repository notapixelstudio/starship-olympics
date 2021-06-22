# Player Ship
extends Ship

const THRESHOLD = 0.07
const DEADZONE = 0.5
const FIRE_TICK = 0.1

var device_controller_id : int

func _ready():
	cpu = false
	device_controller_id = InputMap.get_action_list(controls+"_right")[0].device
	connect('dead', self, '_on_dead')
	
func _on_dead(me, killer, for_good=false):
	vibration_feedback()
	
func vibration_feedback(strong=true):
	if "joy" in controls and global.rumbling:
		# Vibrate if joypad
		Input.start_joy_vibration(device_controller_id, 1, 1, 0.4 if strong else 0.2)

func keyboard_handling():
	var target = Vector2()
	# this works for absolute controls in keyboard
	if absolute_controls:
		target.y = int(Input.is_action_pressed(controls+'_down')) - int(Input.is_action_pressed(controls+'_up'))
		target.x = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))
		
	return target
	
func local_handling():
	
	var target = Vector2()
	target.x = Input.get_action_strength(controls+"_right") - Input.get_action_strength(controls+"_left")
	target.y = Input.get_action_strength(controls+"_down") - Input.get_action_strength(controls+"_up")
	return target
	
func control(delta):
	if not controls_enabled:
		return
		
	#var target_vel = Vector2()
	var front = Vector2(cos(rotation), sin(rotation))
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
		rotation_request = front.angle_to(target_velocity)
	
	# if we want tank mode control (relative control)
	# rotation_request = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))

	
	# charge
	if charging:
		charge = charge+delta
	else:
		charge = 0
		
	if not charging and Input.is_action_just_pressed(controls+'_fire') and fire_cooldown <= 0:
		charge()
		
	# fire
	if charging and Input.is_action_just_released(controls+'_fire'):
		fire()
		
	# overcharge
	if charge > MAX_OVERCHARGE:
		fire()
		
	# cooldown
	fire_cooldown -= delta * Engine.time_scale

	.control(delta)
	

