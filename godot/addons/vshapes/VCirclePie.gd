@tool
extends VParametricShape
class_name VCirclePie
## Circle Pie virtual shape.

@export var radius := 100.0 : set = set_radius ## Radius of the circle, in pixels.
@export var precision := 50 : set = set_precision ## The number of sides of the polygon that approximates a full circumference.
@export var from_angle_deg := 0.0 : set = set_from_angle_deg ## Starting angle in degrees (0 is right, 90 is up).
@export var to_angle_deg := 360.0 : set = set_to_angle_deg ## Ending angle in degrees.


func set_radius(v: float) -> void:
	radius = v
	taint()
	
func set_precision(v: int) -> void:
	precision = v
	taint()
	
func set_from_angle_deg(v: float) -> void:
	from_angle_deg = v
	taint()

func set_to_angle_deg(v: float) -> void:
	to_angle_deg = v
	taint()

func _is_full_circle() -> bool:
	var angle_diff = wrapf(to_angle_deg - from_angle_deg, 0.0, 360.0)
	return abs(angle_diff) >= 360.0 - 0.001  # Small epsilon to account for floating-point precision


func update() -> void:
	var from_angle = deg_to_rad(from_angle_deg - 90.0)
	var to_angle = deg_to_rad(to_angle_deg - 90.0)
	var angle_step = (to_angle - from_angle) / precision
	
	points = PackedVector2Array()
	
	if not _is_full_circle():
		# Aadd the center point as the first vertex for pie slices
		points.append(Vector2.ZERO)
		
	# add the vertices along the arc
	for i in range(precision + 1):
		var current_angle = from_angle + i * angle_step
		points.append(Vector2(radius * cos(current_angle), radius * sin(current_angle)))
	
	super.update()

func get_extents() -> Vector2:
	# this is for the worst case (i.e., full circle)
	return Vector2(2*radius, 2*radius)
