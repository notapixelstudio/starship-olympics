@tool
extends VParametricShape
class_name VRoundedRect
## Rounded rectangle virtual shape.

@export var width := 200.0 : set = set_width ## Width of the rectangle, in pixels.
@export var height := 200.0 : set = set_height ## Height of the rectangle, in pixels.
@export var radius := 50.0 : set = set_radius ## Radius of the rounded corners, in pixels.
@export var precision := 50 : set = set_precision ## The number of sides of the polygon that approximates a full circumference.

func set_width(v: float) -> void:
	width = v
	taint()
	
func set_height(v: float) -> void:
	height = v
	taint()
	
func set_radius(v: float) -> void:
	radius = v
	taint()
	
func set_precision(v: int) -> void:
	precision = v
	taint()
	
func _generate_corner(starting_angle, center):
	var sides = int(precision/4.0) #int(round(PI/2*radius*precision))
	var angle = PI/2/sides
	var points = PackedVector2Array()
	for i in range(sides):
		points.append(Vector2(center.x+radius*cos(starting_angle+i*angle),center.y+radius*sin(starting_angle+i*angle)))
		
	return points

func update() -> void:
	if radius > 0.0:
		points = PackedVector2Array()
		points.append(Vector2(-width/2,-height/2+radius))
		points = points + _generate_corner(-PI, Vector2(-width/2+radius,-height/2+radius))
		points.append(Vector2(-width/2+radius,-height/2))
		points.append(Vector2(width/2-radius,-height/2))
		points = points + _generate_corner(-PI/2, Vector2(width/2-radius,-height/2+radius))
		points.append(Vector2(width/2,-height/2+radius))
		points.append(Vector2(width/2,height/2-radius))
		points = points + _generate_corner(0, Vector2(width/2-radius,height/2-radius))
		points.append(Vector2(width/2-radius,height/2))
		points.append(Vector2(-width/2+radius,height/2))
		points = points + _generate_corner(PI/2, Vector2(-width/2+radius,height/2-radius))
		points.append(Vector2(-width/2,height/2-radius))
	else:
		points = PackedVector2Array([
			Vector2(-width/2,-height/2),
			Vector2(width/2,-height/2),
			Vector2(width/2,height/2),
			Vector2(-width/2,height/2)
		]) # clockwise!
		
	super.update()

func get_extents() -> Vector2:
	return Vector2(width, height)
