@tool

extends GShape

class_name GRegularPolygon

@export (int) var radius = 100 :
	get:
		return radius # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_radius
@export (float) var sides = 6 :
	get:
		return sides # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_sides
@export (float) var alternating_angle = 0 :
	get:
		return alternating_angle # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_alternating_angle
@export (float) var rotation_degrees = 0 :
	get:
		return rotation_degrees # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_rotation_degrees

func set_radius(value):
	radius = value
	emit_signal('changed')
	
func set_sides(value):
	sides = value
	emit_signal('changed')
	
func set_alternating_angle(value):
	alternating_angle = value
	emit_signal('changed')
	
func set_rotation_degrees(value):
	rotation_degrees = value
	emit_signal('changed')

func to_PoolVector2Array():
	var angle = 2*PI/sides
	var current_a = deg_to_rad(rotation_degrees)
	var points = []
	for i in range(sides):
		current_a += angle + (deg_to_rad(alternating_angle) if i %2 else -deg_to_rad(alternating_angle))
		points.append(Vector2(radius*cos(current_a),radius*sin(current_a)))
		
	return super.clip(points) # clockwise!
	
func to_Shape2D():
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(to_PoolVector2Array())
	return shape
	
func get_extents() -> Vector2:
	var points = self.to_PoolVector2Array()
	var rect := Rect2(Vector2(0,0), Vector2(0,0))
	for p in points:
		rect = rect.expand(p)
	return rect.size
	
