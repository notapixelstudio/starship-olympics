@tool
extends VParametricShape
class_name VRect
## Rectangle virtual shape.

@export var width := 200.0 : set = set_width ## Width of the rectangle, in pixels.
@export var height := 200.0 : set = set_height ## Height of the rectangle, in pixels.


func set_width(v: float) -> void:
	width = v
	taint()
	
func set_height(v: float) -> void:
	height = v
	taint()
	

func update() -> void:
	points = PackedVector2Array([
		Vector2(-width/2,-height/2),
		Vector2(width/2,-height/2),
		Vector2(width/2,height/2),
		Vector2(-width/2,height/2)
	]) # clockwise!
	
	super.update()

func get_extents() -> Vector2:
	return Vector2(width, height)
