extends Brain

export var debug := false
export var target_location_jitter := 50.0
export var random_dash := true
export var random_fire := true

var target_location = null # (Vector2) will try to reach this location, if not null
var stance := 'aggressive'

func go_to(global_point: Vector2) -> void:
	target_location = global_point + target_location_jitter*Vector2(1,0).rotated(randf()*TAU)
	$NavigationAgent2D.set_target_location(target_location)
	
func forget_current_target_location() -> void:
	target_location = null
	# TBD turn off navigation... but how?
	
func tick():
	# obey the navigation rule of calling get_next_location every frame
	var nav_location = $NavigationAgent2D.get_next_location()
	
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
	# we are already arrived, just stay where we are
	if $NavigationAgent2D.is_navigation_finished():
		return
		
	var front = Vector2(cos(global_rotation), sin(global_rotation))
	
	target_velocity = relative_position.normalized()
	rotation_request = front.angle_to(target_velocity)
	
	# if we are far, attempt a dash
	var distance = relative_position.length()
	if distance > 900 and randf() < 0.3:
		start_charging_to_dash(distance)
		return
		
	# random dash - low priority
	if random_dash and randf() < 0.04:
		start_charging_to_dash(600+1200*randf())
		return
		
	# random fire - lowest priority
	if random_fire and stance == 'aggressive' and randf() < 0.02:
		request_fire()

func _ready():
	think()
	
	Events.connect("holdable_loaded", self, '_on_holdable_loaded')
	Events.connect("holdable_swapped", self, '_on_holdable_swapped')
	Events.connect("holdable_dropped", self, '_on_holdable_dropped')
	

func think():
	var targets
	
	if controllee.get_cargo().check_class(Ball):
		set_stance('quiet')
		targets = get_tree().get_nodes_in_group('player_ship')
		var escape_vector := Vector2.ZERO
		for target in targets:
			if target != controllee:
				escape_vector -= target.get_target_destination() - global_position
				
		go_to(global_position + escape_vector)
		return
	
	set_stance('aggressive')
	
	targets = get_tree().get_nodes_in_group('Ball')
	if len(targets) > 0:
		go_to(targets[0].global_position)
		return
	
	targets = get_tree().get_nodes_in_group('player_ship')
	for target in targets:
		if target != controllee and target.get_cargo().check_class(Ball):
			go_to(target.get_target_destination())
			break

func _on_ThinkTimer_timeout():
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
	$ReleaseTimer.wait_time = min(distance/1000, 1.0)
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
		'standard':
			bitmask = 1
		'holder':
			bitmask = 2
	$NavigationAgent2D.set_navigation_layers(bitmask)

func _on_holdable_loaded(holdable, ship):
	if ship != controllee:
		return
	set_navigation_layer('holder')
	
func _on_holdable_swapped(holdable1, holdable2, ship1, ship2):
	if ship1 == controllee:
		if holdable1 == null:
			set_navigation_layer('standard')
		else:
			set_navigation_layer('holder')
	elif ship2 == controllee:
		if holdable2 == null:
			set_navigation_layer('standard')
		else:
			set_navigation_layer('holder')

func _on_holdable_dropped(holdable, ship, cause):
	if ship != controllee:
		return
	set_navigation_layer('standard')

func set_stance(v: String) -> void:
	stance = v
	
