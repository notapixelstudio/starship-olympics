extends Ship

onready var debug_ship = $Debug
onready var target_dest = $TargetDest

var this_range = {60:-1, 55:0, 100:1}

var target_hit = []
const MAX_DIR_WAIT = 900
var steering = Vector2()
var front = Vector2()

const DANGER_ZONE = 200
const MAX_AVOIDANCE_FORCE = 10

static func angle_to_angle(from, to):
	return fposmod(to-from + PI, PI*2) - PI

static func which_quadrant(angle:float):
	var tmp = fposmod(angle , (2*PI) )
	if (angle < 0):
		tmp += (2*PI)
	return int(tmp/(PI/2))%4+1
	
var laser_color = Color(1.0, .329, .298)
const MAX_SEE_AHEAD = 200
var hit_pos = []
var behaviour_mode = "seek"

enum BEHAVIOUR {SEEK, AVOID, FLEE, WANDER}

func dist(a: Vector2, b: Vector2):
	return (a-b).length()

func nearest_in(objects, component = "Valuable"):
	var nearest = null
	var min_dist
	for object in objects:
		# avoid considering our own targetdest
		if object == target_dest:
			continue
		var entity = ECM.E(object)
		var checklist = entity.get(component).get_list()
		if len(checklist) > 0 and info_player.id in checklist and not object.is_inside_tree():
			continue
		if not nearest or dist(object.global_position, position) < min_dist:
			nearest = object
			min_dist = dist(nearest.global_position, position)
	return nearest

const CIRCLE_DIST = 50
const CIRCLE_RADIUS = 10
const ANGLE_CHANGE = PI/4
var wander_angle = 0
func set_angle(vector: Vector2, value: float)->Vector2:
	var leng = vector.length()
	vector.x = cos(value) * leng
	vector.y = sin(value) * leng
	return vector
var wander_force = Vector2()
func wander():
	# https://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-wander--gamedev-1624
	var circle_center = front * CIRCLE_DIST
	# let's use front
	var displacement = (front * CIRCLE_RADIUS).rotated(deg2rad(rand_range(-30,30)))
	# Change wanderAngle just a bit, so it
	# won't have the same value in the
	# next game frame.
	wander_angle += randi() * ANGLE_CHANGE - ANGLE_CHANGE * .5
	wander_force = circle_center + displacement
	return (wander_force)
	

func get_ahead()-> PoolVector2Array:
	var pool = PoolVector2Array()
	for pixels in [-45, -20, 0, 20, 45]:
		pool.append(front.rotated(deg2rad(pixels)) * MAX_SEE_AHEAD)
	return pool

const MAX_AVOID = 10
var avoid_lock = 0
func seek_ahead(potential_target):
	# https://docs.godotengine.org/en/3.1/tutorials/physics/ray-casting.html
	# https://gamedevelopment.tutsplus.com/series/understanding-steering-behaviors--gamedev-12732
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	avoid_lock -=1
	#if avoid_lock > 0:
	# return avoidance
	# see if we have some obstacle in front of us
	var becareful = get_ahead()
	hit_pos = []
	for ahead in becareful:
		var danger1 = position + ahead
		var danger2 = position + ahead * 0.5
		# it's not dangerous get in a field pow(2,7) that's why we don't avoid it
		var ray_collision_mask : int = collision_mask - pow(2,0) - pow(2,1) -pow(2,7) - pow(2,10) + pow(2,2) + pow(2,3) + pow(2,8) + pow(2,19)
		# we need to see if we can avoid the castle
		var what = entity.get('Cargo').what
		if entity.could_have("Royal") and entity.has("Royal") and what.type == Crown.types.CROWN:
			ray_collision_mask += pow(2, 15)
			potential_target = null
		var result = space_state.intersect_ray(position, danger1, [self], ray_collision_mask, true, true)
		hit_pos.append(danger1)
		if result and result.position != potential_target:
			#avoidance = position - result.position
			#avoidance = avoidance.normalized() * MAX_AVOIDANCE_FORCE
			avoidance = result.normal * MAX_AVOIDANCE_FORCE
			behaviour_mode = "avoid"
			avoid_lock = MAX_AVOID
			return (avoidance)
	avoidance = Vector2()
	if potential_target != null:
		behaviour_mode = "seek"
		return (potential_target - position)
	else:
		behaviour_mode = "wander"
		return wander()
	
var avoidance

"""
# this draws are for debugging the targets of the CPU
func _draw():
	for hit in target_hit:
		draw_circle((hit - position).rotated(-rotation), 5, laser_color)
		draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)
	
func _physics_process(delta):
	 update()
"""

var last_target_pos = Vector2()

func choose_dir(target):
	"""
	# Follow the Crown or the crown holder if you are not it
	# if you are just run away
	"""
	var direction_to_take = 0
	var target_pos = last_target_pos
	if target != null:
		target_pos = target
	else:
		target_pos = front
	last_target_pos = target_pos
	var distance_to_target = target_pos
	target_velocity = distance_to_target.normalized()
	
	front = Vector2(cos(rotation), sin(rotation))
	direction_to_take = find_side(Vector2(0,0), front, target_velocity)
	
	return direction_to_take

var wait_for_chargedshot = 30
const MIN_WAIT_SHOT = 2*30 #frame
func choose_fire():
	if wait_for_chargedshot < 0:
		# next charged shot will be
		wait_for_chargedshot = MIN_WAIT_SHOT*2 + randi()%MIN_WAIT_SHOT
		charging_time = randi()%(MIN_WAIT_SHOT)
		return true
	# randomly choose to charge shot
	return false

func _ready():
	debug_enabled = true
	cpu = true
	absolute_controls = true

const MAX_WAIT = 200
var wait = MAX_WAIT
var target 

var charging_time : int = 0

func control(delta):
	var this_target = nearest_in(ECM.hosts_with('Valuable'))
	
	"""
	if not this_target or not this_target.is_inside_tree():
		this_target = nearest_in(ECM.hosts_with('Royal'))
	"""
	target_hit = []
	if this_target:
		this_target = this_target.global_position
		target_hit.append(this_target)
	
	# check if there is a danger closer
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
	
	if not charging and choose_fire() and fire_cooldown <= 0:
		charge()
		
	charging_time -= 1
	wait_for_chargedshot -= 1*arena.time_scale
	
	# overcharge
	if charge > MAX_OVERCHARGE or (charging and charging_time < 0):
		fire()
		
	# cooldown
	fire_cooldown -= delta
	
	# dash
	#if Input.is_action_just_pressed(player+'_dash') and dash_cooldown <= 0:
	#	speed_multiplier = 3
	#	$TrailParticles.emitting = true
	#	dash_cooldown = 1
	
func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2)

func _on_DetectionArea_body_entered(body):
	if body is Ship and body != self:
		fire()
