@tool
extends VParametricShape
class_name VMultiBeveledRect

@export var width := 200.0 : set = set_width
@export var height := 200.0 : set = set_height
@export var bevel_nw := 50.0 : set = set_bevel_nw
@export var bevel_ne := 50.0 : set = set_bevel_ne
@export var bevel_sw := 50.0 : set = set_bevel_sw
@export var bevel_se := 50.0 : set = set_bevel_se

func set_width(v: float) -> void:
	width = v
	taint()
	
func set_height(v: float) -> void:
	height = v
	taint()
	
func set_bevel_nw(value: float) -> void:
	bevel_nw = value
	taint()
	
func set_bevel_ne(value: float) -> void:
	bevel_ne = value
	taint()
	
func set_bevel_sw(value: float) -> void:
	bevel_sw = value
	taint()
	
func set_bevel_se(value: float) -> void:
	bevel_se = value
	taint()
	

func update() -> void:
	points = PackedVector2Array([
		Vector2(-width/2,-height/2+bevel_nw),
		Vector2(-width/2+bevel_nw,-height/2),
		Vector2(width/2-bevel_ne,-height/2),
		Vector2(width/2,-height/2+bevel_ne),
		Vector2(width/2,height/2-bevel_se),
		Vector2(width/2-bevel_se,height/2),
		Vector2(-width/2+bevel_sw,height/2),
		Vector2(-width/2,height/2-bevel_sw)
	]) # clockwise!
	
	super.update()

func get_extents() -> Vector2:
	return Vector2(width, height)
