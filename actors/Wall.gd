tool

extends StaticBody2D

export (PoolVector2Array) var points setget set_points

export (bool) var hollow setget set_hollow

func set_points(pts):
	points = pts
	if has_node('CollisionShape2D'):
		refresh()
		
func set_hollow(h):
	hollow = h
	if has_node('CollisionShape2D'):
		refresh()
		
func _ready():
	refresh()
	
func refresh():
	var shape
	
	if points == null or len(points) < 3:
		points = PoolVector2Array([Vector2(-100,-100),Vector2(100,-100),Vector2(100,100),Vector2(-100,100)]) # clockwise!
		
	if hollow:
		shape = ConcavePolygonShape2D.new()
		
		# create segments
		var segments = PoolVector2Array()
		for p in points:
			segments.append(p)
			segments.append(p)
			
		segments.remove(0)
		segments.append(points[0])
		
		shape.set_segments(segments)
	else:
		shape = ConvexPolygonShape2D.new()
		shape.set_points(points)
		
	$CollisionShape2D.set_shape(shape)
	$Polygon2D.set_polygon(points)
	
	$Polygon2D.visible = not hollow
	
	# close the line with a seamless join
	var ps = PoolVector2Array(points)
	ps.remove(0)
	var p = points[0]+(points[1]-points[0])*0.5
	$line.points = PoolVector2Array([p]) + ps + PoolVector2Array([points[0], p])