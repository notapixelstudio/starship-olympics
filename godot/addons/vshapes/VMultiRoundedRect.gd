@tool
extends VParametricShape
class_name VMultiRoundedRect

@export var width := 200.0 : set = set_width
@export var height := 200.0 : set = set_height
@export var radius_nw := 50.0 : set = set_radius_nw
@export var radius_ne := 50.0 : set = set_radius_ne
@export var radius_sw := 50.0 : set = set_radius_sw
@export var radius_se := 50.0 : set = set_radius_se
@export var precision := 50 : set = set_precision ## The number of sides of the polygon that approximates a full circumference.

func set_width(v: float) -> void:
	width = v
	taint()
	
func set_height(v: float) -> void:
	height = v
	taint()
	
func set_radius_nw(value: float) -> void:
	radius_nw = value
	taint()
	
func set_radius_ne(value: float) -> void:
	radius_ne = value
	taint()
	
func set_radius_sw(value: float) -> void:
	radius_sw = value
	taint()
	
func set_radius_se(value: float) -> void:
	radius_se = value
	taint()
	
func set_precision(v: int) -> void:
	precision = v
	taint()

func _generate_corner(starting_angle, center, radius):
	var sides = int(precision/4.0) #int(round(PI/2*radius*precision))
	var angle = PI/2/sides
	var points = PackedVector2Array()
	for i in range(sides):
		points.append(Vector2(center.x+radius*cos(starting_angle+i*angle),center.y+radius*sin(starting_angle+i*angle)))
		
	return points

func update() -> void:
	points = PackedVector2Array()
	points.append(Vector2(-width/2,-height/2+radius_nw))
	if radius_nw > 0.0:
		points = points + _generate_corner(-PI, Vector2(-width/2+radius_nw,-height/2+radius_nw), radius_nw)
		points.append(Vector2(-width/2+radius_nw,-height/2))
	points.append(Vector2(width/2-radius_ne,-height/2))
	if radius_ne > 0.0:
		points = points + _generate_corner(-PI/2, Vector2(width/2-radius_ne,-height/2+radius_ne), radius_ne)
		points.append(Vector2(width/2,-height/2+radius_ne))
	points.append(Vector2(width/2,height/2-radius_se))
	if radius_se > 0.0:
		points = points + _generate_corner(0, Vector2(width/2-radius_se,height/2-radius_se), radius_se)
		points.append(Vector2(width/2-radius_se,height/2))
	points.append(Vector2(-width/2+radius_sw,height/2))
	if radius_sw > 0.0:
		points = points + _generate_corner(PI/2, Vector2(-width/2+radius_sw,height/2-radius_sw), radius_sw)
		points.append(Vector2(-width/2,height/2-radius_sw))
	
	super.update()

func get_extents() -> Vector2:
	return Vector2(width, height)
