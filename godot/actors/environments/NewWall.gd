tool

extends StaticBody2D

class_name NewWall

export (bool) var hollow setget set_hollow

export (int) var offset setget set_offset
export (int) var elongation setget set_elongation

var cshapes = []
	
func set_hollow(h):
	hollow = h
	if has_node('Polygon2D'):
		refresh()
	
func set_offset(o):
	offset = o
	if has_node('Polygon2D'):
		refresh()
		
func set_elongation(e):
	elongation = e
	if has_node('Polygon2D'):
		refresh()
	
func _ready():
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
		return 'This node needs a GShape child!\n'
	return ''
	
func refresh():
	remove_old_shapes()
	
	var gshape = get_gshape()
	
	if not gshape:
		return
		
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

func _on_GShape_changed():
	refresh()
