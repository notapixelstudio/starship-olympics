tool
extends Node2D

class_name Portal

export var linked_to_path : NodePath
export var width : float = 300 setget set_width
export var offset : float = 80
export var color : Color = Color(1, 0, 1, 1) setget set_color
export var inverted : bool = false setget set_inverted

onready var wall = $StaticBody2D

func set_width(v):
	width = v
	refresh()
	
func set_color(v):
	color = v
	refresh()
	
func set_inverted(v):
	inverted = v
	refresh()

func _ready():
	refresh()
	
func refresh():
	if is_inside_tree():
		$Area2D/CollisionShape2D.shape.extents.x = width
		$StaticBody2D/CollisionShape2D.shape.extents.x = width
		
		$Line2D.points[0].x = -width
		$Line2D.points[1].x = width
		$WallLine.points[0].x = -width
		$WallLine.points[1].x = width
		$Hole.points[0].x = -width*0.66
		$Hole.points[1].x = width*0.66
		
		$Line2D.modulate = color
		$Particles2D.modulate = color
		$SpikeParticles2D.modulate = color
		$Particles2D.scale.x = -1 if inverted else 1
		$Particles2D2.scale.x = -1 if inverted else 1
		
func enable():
	$Area2D/CollisionShape2D.disabled = false
	$StaticBody2D/CollisionShape2D.disabled = false
	
func disable():
	$Area2D/CollisionShape2D.disabled = true
	$StaticBody2D/CollisionShape2D.disabled = true
	
func _on_Area2D_body_entered(body : PhysicsBody2D):
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
		
		teleportable.set_destination(linked_to.position + vector.project(Vector2(0,-1).rotated(rotation+PI)) + offset*Vector2(-1,0).rotated(rotation+PI))
		
		var had_thrusters = false
		if entity.has('Thrusters'):
			had_thrusters = true
			entity.get('Thrusters').disable()
			
		yield(get_tree().create_timer(0.1), 'timeout')
		
		if had_thrusters:
			entity.get('Thrusters').enable()
			
		if body is Ship:
			body.recheck_colliding()
		
		body.remove_collision_exception_with(wall)
		body.remove_collision_exception_with(linked_to.wall)
		if teleportable:
			teleportable.enable()
		
