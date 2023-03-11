tool

extends Node2D

class_name MyPortal

export var linked_to_path : NodePath
var linked_to : MyPortal

export var offset : float = 30 setget set_offset

func set_offset(value):
	offset = value
	refresh()
	
func _on_GShape_changed():
	refresh()
	
func _ready():
	refresh()
	
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func refresh():
	var gshape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed', self, '_on_GShape_changed'):
		gshape.connect('changed', self, '_on_GShape_changed')
		
	linked_to = get_node(linked_to_path)
	var points = gshape.to_PoolVector2Array()
	$Line2D.points = points
	
	var a = points[0]
	var b = points[1]
	$Area2D/CollisionShape2D.shape.set_points(PoolVector2Array([
		Vector2(a.x-offset,a.y-offset),
		Vector2(a.x+offset,a.y-offset),
		Vector2(b.x+offset,b.y+offset),
		Vector2(b.x-offset,b.y+offset)
	]))
	
	# workaround for losing texture mode
	$Line2D.texture_mode = Line2D.LINE_TEXTURE_TILE
	
func _on_Area2D_body_entered(body):
	var entity = ECM.E(body)
	
	if not entity:
		return
	
	if entity.has('Teleportable'):
		var teleportable = entity.get('Teleportable')
		var offset = body.position - position
		offset = offset.rotated(-rotation)
		offset.x = -offset.x
		offset = offset.rotated(rotation)
		teleportable.disable()
		teleportable.set_destination(linked_to.position + offset)
		yield(get_tree().create_timer(0.1), 'timeout')
		if teleportable:
			teleportable.enable()
		
