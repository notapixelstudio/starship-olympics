extends Brain
class_name CPUBrain

export var debug := false
export var target_location_jitter := 50.0
export var random_dash_p := 0.04
export var random_fire_p := 0.02
export var think_time := 0.2
export var think_time_jitter := 0.04
export var start_time_jitter := 0.5

var target_location = null # (Vector2) will try to reach this location, if not null
var stance := 'aggressive'
var home_global_position : Vector2

func go_to(global_point: Vector2) -> void:
	target_location = global_point + target_location_jitter*Vector2(1,0).rotated(randf()*TAU)
	$NavigationAgent2D.set_target_location(target_location)
	
func go_home() -> void:
	go_to(home_global_position)
	log_strategy('go home')
	
func forget_current_target_location() -> void:
	target_location = null
	# TBD turn off navigation... but how?
	if debug:
		$DebugSprite.visible = false
	
func tick():
	# obey the navigation rule of calling get_next_location every frame
	var nav_location = $NavigationAgent2D.get_next_location()
	
	if controllee.has_method('are_controls_enabled') and not controllee.are_controls_enabled():
		return
	
	# reset
	target_velocity = Vector2.ZERO
	rotation_request = 0.0
	
	# no target to go to, just stay where we are
	if target_location == null:
		return
		
	if debug:
		update_debug()
	
	# use the position given by the navigation system, rather than the target location as it is
	var relative_position = nav_location - global_position
	
	var front = Vector2(cos(global_rotation), sin(global_rotation))
	
	target_velocity = relative_position.normalized()
	rotation_request = front.angle_to(target_velocity)
	
	# we are already arrived, attempt to stay where we are
	if $NavigationAgent2D.is_navigation_finished():
		return
		
	# if we are far, attempt a dash
	var distance = relative_position.length()
	if distance > 900 and randf() < 0.3:
		start_charging_to_dash(distance)
		return
		
	# random dash - low priority
	if randf() < random_dash_p:
		start_charging_to_dash(300+1200*randf())
		return
		
	# random fire - lowest priority
	if stance == 'aggressive' and randf() < random_fire_p:
		request_fire()
	
func think():
	pass
	
func compute_think_time():
	$ThinkTimer.wait_time = think_time + think_time_jitter*2*(0.5-randf())
	
func _ready():
	home_global_position = global_position
	compute_think_time()
	$ThinkTimer.wait_time += start_time_jitter*randf()
	$ThinkTimer.start()
	
func _on_ThinkTimer_timeout():
	compute_think_time()
	think()

func update_debug() -> void:
	$DebugSprite.visible = not $NavigationAgent2D.is_navigation_finished()
	$DebugSprite.global_position = target_location
	$DebugSprite.global_scale = Vector2(1,1)
	$DebugSprite.global_rotation = 0
	$DebugSprite.modulate = Color(0,1,0,1) if $NavigationAgent2D.is_target_reachable() else Color(1,0,0,1)
	$"%Path".global_position = Vector2.ZERO

func _on_NavigationAgent2D_path_changed():
	$"%Path".points = $NavigationAgent2D.get_nav_path()

func start_charging_to_dash(distance) -> void:
	# skip if we are already charging or we are in cooldown
	if not $ReleaseTimer.is_stopped() or not $DashCooldownTimer.is_stopped():
		return
		
	emit_signal("charge")
	$ReleaseTimer.wait_time = (min(distance/1000, 0.8))
	$ReleaseTimer.start()
	
func request_fire():
	emit_signal("charge")
	emit_signal("release")

func _on_ReleaseTimer_timeout():
	emit_signal("release")
	$DashCooldownTimer.start()
	
func set_navigation_layer(layer_name: String):
	# TBD clean up and see if there's a better way
	var bitmask : int
	match(layer_name):
		'default':
			bitmask = 1
		'holder':
			bitmask = 2
	$NavigationAgent2D.set_navigation_layers(bitmask)
	
func set_stance(v: String) -> void:
	stance = v
	if debug:
		$"%StanceLabel".text = stance
	
func log_strategy(txt: String) -> void:
	if not debug:
		return
	$"%StrategyLabel".text = txt
	
func get_danger_points_ahead() -> Array:
	var dangers := []
	
	for body in $DangerArea2D.get_overlapping_bodies():
		if (body is Bomb or body is Pew) and body.get_team() != controllee.get_team():
			dangers.append(body.global_position)
			
	for area in $DangerArea2D.get_overlapping_areas():
		if area is Explosion:
			dangers.append(area.global_position)
			
	return dangers

func compute_average_position(positions) -> Vector2:
	var result := Vector2(0,0)
	for p in positions:
		result += p
	return result / float(len(positions))

func compute_nearest(nodes: Array) -> Node2D:
	var nearest = nodes[0]
	var d = nearest.global_position.distance_squared_to(global_position)
	for node in nodes:
		var new_d = (node as Node2D).global_position.distance_squared_to(global_position)
		if new_d < d:
			nearest = node
			d = new_d
	return nearest
