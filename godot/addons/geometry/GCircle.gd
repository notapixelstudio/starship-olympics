@tool

extends GShape

class_name GCircle

@export (int) var radius = 100 :
	get:
		return radius # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_radius
@export (float) var precision = 100 :
	get:
		return precision # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_precision

func set_radius(value):
	radius = value
	emit_signal('changed')
	
func set_precision(value):
	precision = value
	emit_signal('changed')

func to_PoolVector2Array():
	var sides = int(round(2*PI*radius/precision))
	var angle = 2*PI/sides
	var points = []
	for i in range(sides):
		points.append(Vector2(radius*cos(i*angle),radius*sin(i*angle)))
		
	return super.clip(points) # clockwise!
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array())
	return shape
	
func to_concave_Shape2D():
	var shape = ConcavePolygonShape2D.new()
	
	# duplicate points to make segments
	var points = []
	var array = to_PoolVector2Array()
	for i in len(array)-1:
		points.append(array[i])
		points.append(array[i+1])
	
	# close the shape
	points.append(array[-1])
	points.append(array[0])
	
	shape.set_segments(PackedVector2Array(points))
	return shape
	
func get_extents() -> Vector2:
	return Vector2(2*radius, 2*radius)
	
