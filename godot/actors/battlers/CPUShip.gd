extends Ship

var this_range = {60:-1, 55:0, 100:1}

const MAX_DIR_WAIT = 20
var wait_direction = MAX_WAIT
var steering = Vector2()
var front = Vector2()

static func angle_to_angle(from, to):
    return fposmod(to-from + PI, PI*2) - PI

static func which_quadrant(angle:float):
	var tmp = fposmod(angle , (2*PI) )
	if (angle < 0):
		 tmp += (2*PI)
	return int(tmp/(PI/2))%4+1
	
func _input(_event):
	pass


func choose_dir(target:Node2D):
	"""
	# Follow the Crown or the crown holder if you are not it
	# if you are just run away
	"""
	var direction_to_take = 0
	if not target or not target.is_inside_tree():
		if wait_direction < 0:
			target_velocity = Vector2(rand_range(-1,1), rand_range(-1,1)).normalized()
			wait_direction = randi() % MAX_DIR_WAIT
	else:
		var distance_to_target = (target.position-position)
		target_velocity = distance_to_target.normalized()
	front = Vector2(cos(rotation), sin(rotation))
	direction_to_take = find_side(Vector2(0,0), front, target_velocity)
		
	return direction_to_take

func choose_fire():
	return false

func _ready():
	absolute_controls = true
const MAX_WAIT = 200
var wait = MAX_WAIT

func control(delta):
	if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
		arena.mouse_target = get_global_mouse_position()
	var this_target = arena.crown
	if not this_target or not this_target.is_inside_tree():
		this_target = arena.game_mode.queen
	if self == this_target:
		this_target = null
		
	rotation_dir = choose_dir(this_target)
	
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
		
	if wait < 0:
		fire()
		wait = randi() % MAX_WAIT
	wait -= 1
	wait_direction -= 1
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
	