@tool
extends VParametricShape
class_name VEllipse
## Ellipse virtual shape.

@export var rx := 100.0 : set = set_rx ## Horizontal radius of the ellipse, in pixels.
@export var ry := 200.0 : set = set_ry ## Vertical radius of the ellipse, in pixels.
@export var precision := 50 : set = set_precision ## The number of sides of the polygon that approximates a full circumference.


func set_rx(v: float) -> void:
	rx = v
	taint()
	
func set_ry(v: float) -> void:
	ry = v
	taint()
	
func set_precision(v: int) -> void:
	precision = v
	taint()
	

func update() -> void:
	var angle = 2*PI/precision
	points = PackedVector2Array()
	for i in range(precision):
		points.append(Vector2(rx*cos(i*angle),ry*sin(i*angle)))
	
	super.update()

func get_extents() -> Vector2:
	return Vector2(2*rx, 2*ry)
