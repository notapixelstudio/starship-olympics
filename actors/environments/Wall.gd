tool

extends StaticBody2D

class_name Wall

export (PoolVector2Array) var points setget set_points

export (bool) var hollow setget set_hollow

export (int) var offset setget set_offset
export (int) var elongation setget set_elongation

var cshapes = []

func set_points(pts):
	points = pts
	if has_node('Polygon2D'):
		refresh()
	
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
	
func refresh():
	remove_old_shapes()
	
	if points == null or len(points) < 3:
		points = PoolVector2Array([Vector2(-100,-100),Vector2(100,-100),Vector2(100,100),Vector2(-100,100)]) # clockwise!
		
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