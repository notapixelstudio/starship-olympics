extends Ship

var this_range = {60:-1, 55:0, 100:1}

var target_velocity = Vector2()
var steering = Vector2()
var front = Vector2()

static func angle_to_angle(from, to):
    return fposmod(to-from + PI, PI*2) - PI

static func which_quadrant(angle:float):
	var tmp = fposmod(angle , (2*PI) )
	if (angle < 0):
		 tmp += (2*PI)
	return int(tmp/(PI/2))%4+1
	

func _input(event):
	if event.is_action_pressed("kb1_fire"):
		alive = not alive
		
func choose_dir(target:Node2D):
	var direction_to_take = 0
	if not target or not target.is_inside_tree():
		var chance = randi() % 100
		for dir in this_range.keys():
			if chance < dir:
				return this_range[dir]
	else:
		var distance_to_target = (target.position-position)
		target_velocity = distance_to_target.normalized()
		front = Vector2(cos(rotation), sin(rotation))
		
		direction_to_take = find_side(Vector2(0,0), front, target_velocity)
		
		return direction_to_take

func choose_fire():
	return false

func control(delta):
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		print("click")
		arena.mouse_target = get_global_mouse_position()
	
	rotation_dir = choose_dir(arena.crown)
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
	
	# fire
	if charging and this_range[randi()%len(this_range)]:
		fire()
		
	if not charging and choose_fire() and fire_cooldown <= 0:
		charging = true
		$Graphics/ChargeBar.visible = true
		
	
	# overcharge
	if charge > MAX_OVERCHARGE:
		fire()
		
	# cooldown
	fire_cooldown -= delta
	$Debug.rotation = -rotation
	
	# dash
	#if Input.is_action_just_pressed(player+'_dash') and dash_cooldown <= 0:
	#	speed_multiplier = 3
	#	$TrailParticles.emitting = true
	#	dash_cooldown = 1
	