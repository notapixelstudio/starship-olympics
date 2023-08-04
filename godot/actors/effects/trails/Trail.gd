extends Line2D
class_name Trail

@export var host : Node2D
@export var offset := Vector2(0, 0)
@export var growing := true : set = set_growing
@export_range (0.0, 100000.0, 10.0, 'suffix:px/s') var shrink_speed := 500.0

@export_group('Trail size')
@export var count_criterion := true
@export var length_criterion := false
@export var age_criterion := false
@export_range(0, 100000, 1) var max_point_count := 100
@export_range(0, 100000, 1, 'suffix:px') var max_length := 150
@export_range(0.0, 100000.0, 0.1, 'suffix:s') var max_age := 1.0

var curve := Curve2D.new()
var timestamps := []
var length : float

func set_growing(v: bool) -> void:
	growing = v
	
func _ready():
	length = max_length
	
func _process(delta):
	assert(curve.get_point_count() == timestamps.size())
	
	# reduce the trail length if not growing
	if not growing:
		length = max(0, length - shrink_speed*delta)
	else:
		length = max_length
		
	var new_point := compute_new_point()
	
	# add the new point only if it is far enough from the last one
	if curve.get_point_count() == 0 or new_point.distance_to(curve.get_point_position(curve.get_point_count()-1)) > 0.1:
		curve.add_point(new_point)
		timestamps.append(Time.get_ticks_msec())
	
	while (count_criterion and curve.get_point_count() > max_point_count) or (length_criterion and curve.get_baked_length() > length) or (age_criterion and timestamps.size() > 0 and Time.get_ticks_msec()-timestamps[0] > max_age*1000.0):
		curve.remove_point(0)
		timestamps.pop_front()
		
	redraw()
	
func compute_new_point() -> Vector2:
	return host.global_position + offset.rotated(host.global_rotation)
	
func redraw() -> void:
	set_points(curve.get_baked_points())

func clear():
	curve.clear_points()
	timestamps.clear()
	clear_points()
