@tool
extends Area2D

@export var max_time = 10
var last_time = max_time

@export var active = false :
	get:
		return active # TODOConverter40 Copy here content of get_active
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_active
var player :
	get:
		return player # TODOConverter40 Copy here content of get_player
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_player

signal disappeared

func set_active(v):
	active = v
	
	if not is_inside_tree():
		await self.ready
	
	if active:
		$AnimationPlayer.play("Appear")
		add_to_group('in_camera')
		setup_clock()
		refresh_clock()
	else:
		remove_from_group('in_camera')
		
	await get_tree().idle_frame
	$Background.visible = active
	$Crown.visible = active
	$Border.visible = active
	
func get_active():
	return active
	
func set_player(v):
	player = v
	
	if player != null:
		$Background.modulate = player.species.color
		$Border.modulate = player.species.color
		$Border.self_modulate = Color(1.3,1.3,1.3)
		$Crown.modulate = player.species.color
		$Wrapper.modulate = player.species.color
		$Wrapper/Crown.visible = true
		$Wrapper/Monogram.text = player.species.get_monogram()
	else:
		$Background.modulate = Color(1,1,1,0.2)
		$Border.modulate = Color(1,1,1)
		$Border.self_modulate = Color(1.1,1.1,1.1)
		$Crown.modulate = Color(1,1,1)
		$Wrapper.modulate = Color(1,1,1)
		$Wrapper/Crown.visible = false
		$Wrapper/Monogram.text = ''
		
func get_player():
	return player

func _ready():
	refresh_polygon()
	$GShape.connect('changed',Callable(self,'refresh_polygon'))
	setup_clock()
	
func setup_clock():
	$Timer.wait_time = max_time
	set_process(false)
	
func _process(delta):
	refresh_clock()
	
func refresh_clock():
	$Background.material.set_shader_parameter('time_left', $Timer.time_left)
	
func refresh_polygon():
	var polygon = $GShape.to_PoolVector2Array()
	$CollisionPolygon2D.polygon = polygon
	
	var castle_points = []
	var margin = 100
	
	castle_points.append(polygon[0]+Vector2(0,margin))
	castle_points.append(polygon[0]+Vector2(margin,margin))
	castle_points.append(polygon[0]+Vector2(margin,0))
	
	castle_points.append(polygon[1]+Vector2(-margin,0))
	castle_points.append(polygon[1]+Vector2(-margin,margin))
	castle_points.append(polygon[1]+Vector2(0,margin))
	
	castle_points.append(polygon[2]+Vector2(0,-margin))
	castle_points.append(polygon[2]+Vector2(-margin,-margin))
	castle_points.append(polygon[2]+Vector2(-margin,0))
	
	castle_points.append(polygon[3]+Vector2(margin,0))
	castle_points.append(polygon[3]+Vector2(margin,-margin))
	castle_points.append(polygon[3]+Vector2(0,-margin))
	
	castle_points.append(polygon[0]+Vector2(0,margin))
	
	$Border.points = PackedVector2Array(castle_points)
	$Background.polygon = PackedVector2Array(castle_points)
	
	$Border/Tower1.position = polygon[0]
	$Border/Tower2.position = polygon[1]
	$Border/Tower3.position = polygon[2]
	$Border/Tower4.position = polygon[3]
	
func take_control(p):
	$AnimationPlayer.play("Taken")
	set_player(p)
	set_process(true)
	$Timer.start(last_time)
	$Background.material.set_shader_parameter('max_time', max_time)
	
func lose_control():
	set_process(false)
	set_player(null)
	last_time = $Timer.time_left
	$Timer.stop()
	
	
func _on_Zone_body_entered(body):
	if active and (not $AnimationPlayer.is_playing() or $AnimationPlayer.current_animation != 'Disappear') and body is Ship and get_player() == null:
		take_control(body.get_player())
		
func _on_Zone_body_exited(body):
	if active:
		if body is Ship and body.get_player() == player:
			lose_control()
			
			# check if a single ship is inside the area, to give it control
			var ships = []
			for maybe_ship in get_overlapping_bodies():
				if maybe_ship is Ship and maybe_ship != body:
					ships.append(maybe_ship)
					
			if len(ships) == 1:
				take_control(ships[0].get_player())
	
func _on_Timer_timeout():
	set_process(false)
	$Timer.stop()
	$Background.material.set_shader_parameter('time_left', 0)
	$AnimationPlayer.play("Disappear")
	await $AnimationPlayer.animation_finished
	set_active(false)
	emit_signal('disappeared', self)

func get_strategy(ship, distance, game_mode):
	return {"seek": 10} if active and (get_player() == null or get_player() == ship.get_player()) else {}
	
