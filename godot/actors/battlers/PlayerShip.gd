extends Ship

const THRESHOLD = 0.07
export var absolute_controls : bool= true

func control(delta):
	if absolute_controls:
		var target_vel = Vector2()
		target_vel.y = int(Input.is_action_pressed(controls+'_down')) - int(Input.is_action_pressed(controls+'_up'))
		target_vel.x = int(Input.is_action_pressed(controls+'_right')) - int(Input.is_action_pressed(controls+'_left'))
		
		var front = Vector2(cos(rotation), sin(rotation))
		rotation_dir = find_side(Vector2(0,0), front, target_vel)
		
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
	