extends Brain

export var target_location_jitter := 50.0

var target_location = null # (Vector2) will try to reach this location, if not null

var locations = [
	Vector2(0,0),
	Vector2(700,1000),
	Vector2(-700,1000),
	Vector2(-1200,0),
	Vector2(0,-1000),
	Vector2(-2000,-0)
]
	
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
	if distance > 900:
		start_charging_to_dash(distance)

func think():
	go_to(locations[randi() % len(locations)])

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
	if not $ReleaseTimer.is_stopped():
		return
		
	emit_signal("charge")
	$ReleaseTimer.wait_time = min(distance/750, 1.0)
	$ReleaseTimer.start()

func _on_ReleaseTimer_timeout():
	emit_signal("release")
