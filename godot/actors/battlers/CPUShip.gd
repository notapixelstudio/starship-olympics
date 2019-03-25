extends Ship

var this_range = {60:-1, 55:0, 100:1}

const MAX_DIR_WAIT = 200
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

var laser_color = Color(1.0, .329, .298)
const MAX_SEE_AHEAD = Vector2(50,40)
var hit_pos = []

enum BEHAVIOUR {SEEK, AVOID, FLEE}

func dist(a: Vector2, b: Vector2):
	return (a-b).length()

func nearest_in(objects):
	var nearest = null
	var min_dist
	for object in objects:
		if not nearest or dist(nearest.position, position) < min_dist:
			nearest = object
			min_dist = dist(nearest.position, position)
	return nearest

func seek_ahead(potential_target):
	var res = { "action": BEHAVIOUR.SEEK,
				"target": potential_target
			}
	# see if we have some obstacle in front of us
	var ahead = front * MAX_SEE_AHEAD + position
	var half_ahead = front * MAX_SEE_AHEAD * 0.5 + position
	var targets = []
	for body in $DetectionArea.get_overlapping_bodies():
		targets.append(body)
		# get all the bodies inside the area
	for areas in $DetectionArea.get_overlapping_bodies():
		# get all areas inside the area
		targets.append(areas)
	
	hit_pos = []
	var space_state = get_world_2d().direct_space_state
	var found = false
	for pos_target in targets:
		if found:
			break
		var shapeTarget = pos_target.get_node('CollisionShape2D').shape
		var target_extents
		if shapeTarget is CircleShape2D:
			target_extents = Vector2(shapeTarget.radius, shapeTarget.radius)
		else:
			target_extents = shapeTarget.extents 
		target_extents -= Vector2(5, 5)

		var nw = pos_target.position - target_extents
		var se = pos_target.position + target_extents
		var ne = pos_target.position + Vector2(target_extents.x, -target_extents.y)
		var sw = pos_target.position + Vector2(-target_extents.x, target_extents.y)
		for pos in [pos_target.position, nw, ne, se, sw]:
			var result = space_state.intersect_ray(position,
				pos, [self], collision_mask)
			if result:
				hit_pos.append(result.position)
				if result.collider != potential_target and not result.collider is Ship:
					target = result.collider
					print("THERE IS A DANGER: ", result.collider.name)
					found = true
					break

		return target

#func _draw():
#	for hit in hit_pos:
#		draw_circle((hit - position).rotated(-rotation), 5, laser_color)
#		draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)
	
func _physics_process(delta):
	update()
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
var target 
func control(delta):
	var this_target = get_parent().get_node("Crown")
	if not this_target or not this_target.is_inside_tree():
		var royals = ECM.hosts_with('Royal')
		if len(royals) > 0:
			this_target = nearest_in(royals)
		else:
			this_target = null
	if self == this_target:
		this_target = null
	
	# check if there is a danger closer
	target = this_target
	target = seek_ahead(this_target)
	rotation_dir = choose_dir(target)
	
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
	