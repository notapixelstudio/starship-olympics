tool

extends StaticBody2D

export (bool) var hollow setget set_hollow

export (int) var offset setget set_offset
export (int) var elongation setget set_elongation

enum TYPE { solid, hostile }
export(TYPE) var type = TYPE.solid setget set_type

onready var extents = $RectExtents
onready var gshape = $GBeveledRect
var cshapes = []

func set_hollow(value):
	hollow = value
	refresh()
	
func set_offset(value):
	offset = value
	refresh()
	
func set_elongation(value):
	elongation = value
	refresh()
	
func set_type(value):
	type = value
	refresh()
	
func _ready():
	extents.size = gshape.get_extents()
	refresh()
	
func remove_old_shapes():
	for child in get_children():
		if child is CollisionShape2D:
			remove_child(child)
			child.queue_free()
	
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func _get_configuration_warning():
	if not get_gshape():
		return 'Please provide a GShape as child node to define the geometry.\n'
	return ''
	
func refresh():
	remove_old_shapes()
	
	var gshape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed', self, 'refresh'):
		gshape.connect('changed', self, 'refresh')
		
	var points = gshape.to_PoolVector2Array()
	
	if hollow:
		for i in range(len(points)):
			var cshape = CollisionShape2D.new()
			var shape = ConvexPolygonShape2D.new()
			var a = points[i]
			var b = points[(i+1) % len(points)]
			var elo = (b-a).normalized()*elongation
			shape.set_points(PoolVector2Array([a-elo,a+a.normalized()*offset-elo,b+b.normalized()*offset+elo,b+elo]))
			cshape.set_shape(shape)
			add_child(cshape)
	else:
		var cshape = CollisionShape2D.new()
		var shape = ConvexPolygonShape2D.new()
		shape.set_points(points)
		cshape.set_shape(shape)
		add_child(cshape)
		
	$Polygon2D.set_polygon(points)
	
	$Polygon2D.visible = not hollow
	
	# close the line with a seamless join
	var ps = PoolVector2Array(points)
	ps.remove(0)
	var p = points[0]+(points[1]-points[0])*0.5
	$line.points = PoolVector2Array([p]) + ps + PoolVector2Array([points[0], p])
	
	# wall types
	if type == TYPE.hostile:
		modulate = Color(1,0,0,1)
		$Entity/Deadly.enabled = true
		$Entity/Trigger.enabled = true
	elif type == TYPE.solid:
		modulate = Color(1,1,1,1)
		$Entity/Deadly.enabled = false
		$Entity/Trigger.enabled = false
		