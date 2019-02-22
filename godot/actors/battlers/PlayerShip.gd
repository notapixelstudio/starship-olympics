extends Ship

const THRESHOLD = 0.07
const DEADZONE = 0.5

var device_controller_id : int
func _ready():
	device_controller_id = InputMap.get_action_list(controls+"_right")[0].device
	
	if "joy" in controls:
		print("THIS IS A CONTROLLER ")
	if "kb" in controls:
		absolute_controls = false
		
func die():
	print("DIE FROM PLAYER")
	# randomize the vibration
	Input.start_joy_vibration(device_controller_id,1.0,1.0,2)   
	.die()
	
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
	
	if absolute_controls:
		var target_vel = Vector2()
		# Check for joypad
		if "joy" in controls:
			target_vel = joypad_handling()
		else:
			target_vel.y = int(Input.is_action_pressed(controls+'_down')) - int(Input.is_action_pressed(controls+'_up'))
			target_vel.x = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))
			
		var front = Vector2(cos(rotation), sin(rotation))
		
		if target_vel == Vector2():
			pass
		else:
			target_velocity = target_vel.normalized()
		rotation_dir = find_side(Vector2(0,0), front, target_velocity)
		
	else:
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
		charging = true
		$Graphics/ChargeBar.visible = true
		
	# fire
	if charging and Input.is_action_just_released(controls+'_fire'):
		fire()
		
	# overcharge
	if charge > MAX_OVERCHARGE:
		fire()
		
	# cooldown
	fire_cooldown -= delta
		
	# dash
	#if Input.is_action_just_pressed(player+'_dash') and dash_cooldown <= 0:
	#	speed_multiplier = 3
	#	$TrailParticles.emitting = true
	#	dash_cooldown = 1
	