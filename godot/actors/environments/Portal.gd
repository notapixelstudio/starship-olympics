tool

extends Node2D

class_name Portal

export var linked_to_path : NodePath
var linked_to : Portal

export var thickness : float = 10 setget set_thickness
export var width : float = 100 setget set_width
export var offset : float = 30 setget set_offset

func set_thickness(value):
	thickness = value
	refresh()
	
func set_width(value):
	width = value
	refresh()
	
func set_offset(value):
	offset = value
	refresh()
	
func _ready():
	refresh()
	
func refresh():
	linked_to = get_node(linked_to_path)
	
	$Area2D/CollisionShape2D.shape.extents = Vector2(width, thickness)
	$StaticBody2D/CollisionShape2D.shape.extents = Vector2(width, thickness)
	
	$Line2D.points = PoolVector2Array([
		Vector2(-width, 0),
		Vector2(width, 0)
	])
	$Line2D.width = thickness*10
	
	# workaround for losing texture mode
	$Line2D.texture_mode = Line2D.LINE_TEXTURE_TILE
	
func _on_Area2D_body_entered(body):
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
		teleportable.set_destination(linked_to.position + vector - offset*Vector2(0,1).rotated(rotation))
		if entity.has('Thrusters'):
			entity.get('Thrusters').disable()
			
		yield(get_tree().create_timer(0.1), 'timeout')
		
		if teleportable:
			teleportable.enable()
		if entity.could_have('Thrusters'):
			entity.get('Thrusters').enable()
			
		
