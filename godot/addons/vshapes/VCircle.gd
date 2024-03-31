@tool
extends VParametricShape
class_name VCircle
## Circle virtual shape.

@export var radius := 50.0 : set = set_radius ## Radius of the circle, in pixels.
@export var precision := 50 : set = set_precision ## The number of sides of the polygon that approximates a full circumference.


func set_radius(v: float) -> void:
	radius = v
	taint()
	
func set_precision(v: int) -> void:
	precision = v
	taint()
	

func update() -> void:
	var angle = 2*PI/precision
	var points = []
	for i in range(precision):
		points.append(Vector2(radius*cos(i*angle),radius*sin(i*angle)))
	
	super.update()

func get_extents() -> Vector2:
	return Vector2(2*radius, 2*radius)
