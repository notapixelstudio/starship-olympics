@tool
extends VShape
class_name VBeveledRect

@export var width := 200.0 : set = set_width
@export var height := 200.0 : set = set_height
@export var bevel := 50.0 : set = set_bevel


func set_width(v: int) -> void:
	width = v
	taint()
	
func set_height(v: int) -> void:
	height = v
	taint()
	
func set_bevel(v: int) -> void:
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
