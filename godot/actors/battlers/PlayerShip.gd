# Player Ship
extends Ship

const THRESHOLD = 0.07
const DEADZONE = 0.5
const FIRE_TICK = 0.1

var device_controller_id : int

func _ready():
	cpu = false
	if "remote" in controls:
		device_controller_id = int(RemoteController.players[int(controls.replace("remote", ""))-1])
	else:
		device_controller_id = InputMap.get_action_list(controls+"_right")[0].device
	if "kb" in controls:
		absolute_controls = false
	connect('dead', self, '_on_dead')
	
func _on_dead(me, killer):
	vibration_feedback()
	
func vibration_feedback():
	if "joy" in controls and global.rumbling:
		# Vibrate if joypad
		Input.start_joy_vibration(device_controller_id, 1, 1, 0.3)

func keyboard_handling():
	var target = Vector2()
	# this works for absolute controls in keyboard
	if absolute_controls:
		target.y = int(Input.is_action_pressed(controls+'_down')) - int(Input.is_action_pressed(controls+'_up'))
		target.x = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))
		
	return target

func remote_joypad():
	var analogic = RemoteController.analogics[str(device_controller_id)]
	if analogic != Vector2.ZERO:
		print(analogic)
	var target = Vector2(analogic[0], analogic[1])
	# xAxis is a value from +/0 0-1 depending on how hard the stick is being pressed
	if abs(target.x) < DEADZONE:
		target.x = 0
	if abs(target.y) < DEADZONE:
		target.y = 0
	return target
	
	
func joypad_handling():
	var target = Vector2()
	var analogic: InputEventJoypadMotion
	for action in InputMap.get_action_list(controls+"_right"):
		if action is InputEventJoypadMotion:
			analogic = action
	
	if not analogic:
		assert(analogic is InputEventJoypadMotion)

	# xAxis is a value from +/0 0-1 depending on how hard the stick is being pressed
	target.x = Input.get_joy_axis(analogic.device, JOY_AXIS_0)  
	target.y = Input.get_joy_axis(analogic.device, JOY_AXIS_1)
	if abs(target.x) < DEADZONE:
		target.x = 0
	if abs(target.y) < DEADZONE:
		target.y = 0
	return target
			
func control(delta):
	var target_vel = Vector2()
	var front = Vector2(cos(rotation), sin(rotation))
	if "remote" in controls:
		target_vel = remote_joypad()
	elif "joy" in controls:
		target_vel = joypad_handling()
	else:
		target_vel = keyboard_handling()
	if not target_vel == Vector2():
		absolute_controls = true
		# this works for absolute controls in keyboard
		# target_vel.y = int(Input.is_action_pressed(controls+'_down')) - int(Input.is_action_pressed(controls+'_up'))
		# target_vel.x = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))
		
		if target_vel == Vector2():
			# this in order to keep the velocity constant
			pass
		else:
			target_velocity = target_vel.normalized()
		rotation_dir = find_side(Vector2(0,0), front, target_velocity)
		
	else:
		absolute_controls = false
		rotation_dir = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))
		
	# charge
	if charging:
		charge = charge+delta
	else:
		charge = 0
		
	# charge feedback
	$Graphics/ChargeBar/Charge.set_point_position(1, $Graphics/ChargeBar/ChargeAxis.points[1] * min(charge,MAX_CHARGE)/MAX_CHARGE)
	
	# overcharge feedback
	if charge > MAX_CHARGE + (MAX_OVERCHARGE-MAX_CHARGE)/2:
		$Graphics/ChargeBar.visible = int(floor(charge * 15)) % 2
		
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
	
