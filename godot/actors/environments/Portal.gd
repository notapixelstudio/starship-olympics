@tool
extends Node2D

@export var linked_to_path : NodePath
@export var width : float = 300 :
	get:
		return width # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_width
@export var offset : float = 80
@export var color : Color = Color(1, 0, 1, 1) :
	get:
		return color # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_color
@export var inverted : bool = false :
	get:
		return inverted # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_inverted
@export var show_hole : bool = true :
	get:
		return show_hole # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_show_hole
@export var wobbliness := 20.0
@export var is_goal : bool = false
@export var goal_owner : NodePath
var player

@onready var wall = $StaticBody2D

signal goal_done

func set_width(v):
	width = v
	refresh()
	
func set_color(v):
	color = v
	refresh()
	
func set_inverted(v):
	inverted = v
	refresh()
	
func set_show_hole(v):
	show_hole = v
	refresh()

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		await player_spawner.player_assigned
		set_player(player_spawner.get_player())
	refresh()
	
func refresh():
	if is_inside_tree():
		$Area2D/CollisionShape2D.shape.extents.x = width
		$StaticBody2D/CollisionShape2D.shape.extents.x = width
		
		self.wobble()
		
		$WallLine.points[0].x = -width
		$WallLine.points[1].x = width
		$Hole.points[0].x = -width*0.66
		$Hole.points[1].x = width*0.66
		
		$GPUParticles2D.modulate = color
		$SpikeParticles2D.modulate = color
		$GPUParticles2D.scale.x = -1 if inverted else 1
		$Particles2D2.scale.x = -1 if inverted else 1
		$GPUParticles2D.process_material.emission_box_extents.y = width
		$Particles2D2.process_material.emission_box_extents.y = width
		$SpikeParticles2D.process_material.emission_box_extents.y = width
		$GPUParticles2D.amount = width / 300 * 8
		$Particles2D2.amount = width / 300 * 8
		$SpikeParticles2D.amount = width / 300 * 8
		
		if player:
			$Line2D.modulate = player.species.color
			$GPUParticles2D.modulate = player.species.color
			$SpikeParticles2D.modulate = player.species.color
			$Line2D.self_modulate = Color(1.2,1.2,1.2,1) # ship colors are already vibrant
			
		$Hole.visible = show_hole
		
func enable():
	$Area2D/CollisionShape2D.disabled = false
	$StaticBody2D/CollisionShape2D.disabled = false
	
func disable():
	$Area2D/CollisionShape2D.disabled = true
	$StaticBody2D/CollisionShape2D.disabled = true
	
func _on_Area2D_body_entered(body : PhysicsBody2D):
	var position_before_teleporting = body.position
	var entity = ECM.E(body)
	
	if not entity:
		return
		
	if entity.has('Teleportable'):
		var teleportable = entity.get('Teleportable')
		var vector = body.position - position
		#offset = offset.rotated(-rotation)
		#offset.x = -offset.x
		#offset = offset.rotated(rotation)
		teleportable.disable()
		var linked_to = get_node(linked_to_path)
		body.add_collision_exception_with(wall)
		body.add_collision_exception_with(linked_to.wall)
		
		teleportable.set_destination(linked_to.global_position + vector.project(Vector2(0,-1).rotated(rotation+PI)) + offset*Vector2(-1,0).rotated(rotation+PI))
		
		var had_thrusters = false
		if entity.has('Thrusters'):
			had_thrusters = true
			entity.get('Thrusters').disable()
			
		await get_tree().create_timer(0.1).timeout
		
		if had_thrusters:
			entity.get('Thrusters').enable()
			
		if body is Ship:
			body.recheck_colliding()
			do_goal(body.get_player(), body.position)
			
		if body is Crown and body.type == Crown.types.SOCCERBALL:
			if body.owner_ship and body.owner_ship.get_player() != get_player():
				do_goal(body.owner_ship.get_player(), position_before_teleporting)
			body.owner_ship = null
		
		body.remove_collision_exception_with(wall)
		body.remove_collision_exception_with(linked_to.wall)
		if teleportable:
			teleportable.enable()
		
func get_score():
	return -1 if inverted else 1
	
func do_goal(player, pos):
	if is_goal:
		emit_signal("goal_done", player, self, pos)
	
func set_player(v : InfoPlayer):
	player = v
	
func get_player():
	return player

func wobble():
	var points := []
	var step := 30.0
	var current := -width
	while current < width:
		points.append(Vector2(current, -randf()*wobbliness))
		current += step
		
	$Line2D.points = PackedVector2Array(points)

func _on_Timer_timeout():
	self.wobble()
	
