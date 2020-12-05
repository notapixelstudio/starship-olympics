extends Ship

onready var debug_ship = $Debug
onready var rays = [
	$RayCast2DFront, $"RayCast2D20+", 
	$"RayCast2D20-", $"RayCast2D45+", $"RayCast2D45-"
	]	


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
enum BEHAVIOUR {SEEK, AVOID, FLEE, WANDER, SHOOT}
var possible_behaviours = ["seek", "avoid", "shoot"]

func dist(a: Vector2, b: Vector2):
	return (a-b).length()


	
	
func choose_target(entities, component="Strategic") -> Dictionary:
	"""
	Among the possible target objects choose the highest priority one
	"""
	var best_candidate = null
	var target_pos = null
	var behaviour = "wander"
	var priority = 0
	for entity in entities:
		var object = entity.get_host()
		if object == target_dest:
			# avoid considering our own targetdest
			continue
		var distance = dist(object.global_position, global_position)
		var strategy: Dictionary = entity.get(component).get_strategy(self, distance, self.game_mode)
		
		for key in strategy:
			if not key in self.possible_behaviours:
				continue
			var this_element_priority = strategy[key] / distance
			
			if priority < this_element_priority:
				priority = this_element_priority
				best_candidate = object
				behaviour = key
				target_pos = object.position
	
	var becareful = get_ahead()
	var space_state = get_world_2d().direct_space_state
	for ahead in becareful:
		var danger1 = position + ahead
		var result = space_state.intersect_ray(position, danger1, [self], collision_mask, true, true)
		if result :
			var collider = result.collider
			var e = ECM.E(collider)
			var distance = dist(result.position, global_position)
			if not e.has(component):
				continue
			var strategy = e.get(component).get_strategy(self, distance, game_mode)
			for key in strategy:
				if not key in self.possible_behaviours:
					continue
				var this_element_priority = strategy[key] / distance
				if priority < this_element_priority:
					priority = this_element_priority
					best_candidate = collider
					behaviour = key
					target_pos = result.position - position
					if behaviour == "avoid":
						target_pos = result.normal * MAX_AVOIDANCE_FORCE
			
	return {"target": best_candidate, "behaviour": behaviour, "target_pos": target_pos}
	
func nearest_in(objects, component = "Strategic"):
	var nearest = null
	var min_dist
	var what = entity.get('Cargo').what
	for object in objects:
		# avoid considering our own targetdest
		if object == target_dest:
			continue
		var entity_object = ECM.E(object)
		var checklist = entity_object.get(component).get_list()
		
		# FORCE diamond chasing
		if entity_object.get_host() is Diamond:
			nearest = object
			break
		
		# FORCE to follow whoever has the crown if they have the crown
		if entity_object.get_host() is TargetDest:
			var master_ship = entity_object.get_host().get_master_ship()
			var entity_mastership = ECM.E(master_ship)
			if entity_mastership.could_have("Royal") and entity_mastership.has("Royal"):
				nearest = object
				break
			# FORCE to wander if bombs NOT enabled
			if not bombs_enabled:
				continue
		# run away if you have the crown
		if entity.could_have("Royal") and entity.has("Royal") and what.type == Crown.types.CROWN:
			break
		
		if len(checklist) > 0 and info_player.id in checklist and not object.is_inside_tree():
			continue
		if not nearest or dist(object.global_position, position) < min_dist:
			nearest = object
			min_dist = dist(nearest.global_position, position)
	# FORCE to follow the crown if it's on the battlefield
	
	for object in get_tree().get_nodes_in_group("Crown"):
		nearest=null
		if not nearest or dist(object.global_position, position) < min_dist:
			nearest = object
			min_dist = dist(nearest.global_position, position)
	# FORCE to target the Pentagonion if you HAVE the ball
	if entity.could_have("Royal") and entity.has("Royal") and what.type == Crown.types.BALL:
		nearest = null
		for object in get_tree().get_nodes_in_group("goal"):
			if object.species.species_name != info_player.species.species_name:# or object.current_ring == 0:
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
	hit_pos = []
	for ahead in get_ahead():
		var danger1 = position + ahead
		# it's not dangerous get in a field pow(2,7) that's why we don't avoid it
		var ray_collision_mask : int = collision_mask - pow(2,0) - pow(2,1) -pow(2,7) - pow(2,10) + pow(2,2) + pow(2,3) + pow(2,8) + pow(2,19)
		
		# we need to see if we can avoid the castle
		var what = entity.get('Cargo').what
		if entity.could_have("Royal") and entity.has("Royal") and what.type == Crown.types.CROWN:
			ray_collision_mask += pow(2, 15)
			potential_target = null
		
		
		
	avoidance = Vector2()
	if potential_target != null:
		return (potential_target - position)
	else:
		behaviour_mode = "wander"
		return wander()
	
var avoidance


# this draws are for debugging the targets of the CPU
"""
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
var force_wander = false

func control(delta):
	var chosen_strategy = choose_target(ECM.entities_with('Strategic'))
	var target = chosen_strategy["target_pos"]
	var behaviour = chosen_strategy["behaviour"]
	behaviour_mode = chosen_strategy["behaviour"]
	
	"""
	if not this_target or not this_target.is_inside_tree():
		this_target = nearest_in(ECM.hosts_with('Royal'))
	"""
	
	
	if not target or force_wander or behaviour == "wander":
		target = wander()
	
	rotation_dir = choose_dir(target)
	
	# charge
	if charging:
		if behaviour == "shoot":
			rotation_dir = choose_dir(-target)
		charge = charge+delta
	else:
		charge = 0
	
	# overcharge feedback
	if charge > MAX_CHARGE + (MAX_OVERCHARGE-MAX_CHARGE)/2:
		$Graphics/ChargeBar.visible = int(floor(charge * 15)) % 2
	
	if not charging and choose_fire() and fire_cooldown <= 0:
		charge()
		
	charging_time -= 1
	wait_for_chargedshot -= 1 * Engine.time_scale
	
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
	
	wander_time -=delta
	if wander_time < 0:
		force_wander = not force_wander
		if force_wander:
			wander_time = MIN_WANDER_TIME + (randi() % WANDER_TIME)
			behaviour_mode = "wander"
		else:
			wander_time = MIN_WAIT_FOR_WANDER + (randi() % WAIT_FOR_WANDER)
			
	
	.control(delta)
var wander_time = MIN_WAIT_FOR_WANDER + WAIT_FOR_WANDER
const MIN_WAIT_FOR_WANDER = 4 #  seconds
const WAIT_FOR_WANDER = 4 # seconds
const MIN_WANDER_TIME = 1 # seconds
const WANDER_TIME = 1 #seconds


func _on_DetectionArea_body_entered(body):
	if body is Ship and body != self:
		fire()
