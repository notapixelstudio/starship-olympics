@tool
extends VParametricShape
class_name VRegularPolygon
## Regular polygon virtual shape.


@export var radius = 100.0 : set = set_radius
@export var sides = 6 : set = set_sides
@export var alternating_angle = 0.0 : set = set_alternating_angle
@export var rotation_degrees = 0.0 : set = set_rotation_degrees

func set_radius(v: float) -> void:
	radius = v
	taint()
	
func set_sides(v: int) -> void:
	sides = v
	taint()
	
func set_alternating_angle(v: float) -> void:
	alternating_angle = v
	taint()
	
func set_rotation_degrees(v: float) -> void:
	rotation_degrees = v
	taint()
	

func update() -> void:
	var angle = 2*PI/sides
	var current_a = deg_to_rad(rotation_degrees)
	var points = PackedVector2Array()
	for i in range(sides):
		current_a += angle + (deg_to_rad(alternating_angle) if i %2 else -deg_to_rad(alternating_angle))
		points.append(Vector2(radius*cos(current_a),radius*sin(current_a)))
	
	super.update()

func get_extents() -> Vector2:
	var rect := Rect2(Vector2(0,0), Vector2(0,0))
	for p in points:
		rect = rect.expand(p)
	return rect.size
