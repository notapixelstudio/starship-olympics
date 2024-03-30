@tool
extends VParametricShape
class_name VBeveledRect
## Beveled rectangle virtual shape.

@export var width := 200.0 : set = set_width ## Width of the rectangle, in pixels.
@export var height := 200.0 : set = set_height ## Height of the rectangle, in pixels.
@export var bevel := 50.0 : set = set_bevel ## Size of the bevel (length of the side of the bevel), in pixels.

func set_width(v: float) -> void:
	width = v
	taint()
	
func set_height(v: float) -> void:
	height = v
	taint()
	
func set_bevel(v: float) -> void:
	bevel = v
	taint()
	

func update() -> void:
	points = PackedVector2Array([
		Vector2(-width/2,-height/2+bevel),
		Vector2(-width/2+bevel,-height/2),
		Vector2(width/2-bevel,-height/2),
		Vector2(width/2,-height/2+bevel),
		Vector2(width/2,height/2-bevel),
		Vector2(width/2-bevel,height/2),
		Vector2(-width/2+bevel,height/2),
		Vector2(-width/2,height/2-bevel)
	]) # clockwise!
	
	super.update()

func get_extents() -> Vector2:
	return Vector2(width, height)
