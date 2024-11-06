extends Line2D
class_name Trail

## A special type of [Line2D] that automatically follows a [member host] [Node2D], drawing a trail.

## The host this trail will follow. You must set this in order for the trail to work.
@export var host : Node2D
## An optional offset vector (in px) to change where the trail is attached to the host.
@export var offset := Vector2(0, 0)
## If true, the trail will reduce its length until it reaches zero. Works only if [member length_criterion] is true.
@export var shrinking := false : set = set_shrinking
## The rate (px/s) at which the trail reduces its length while shrinking.
@export_range (0.0, 100000.0, 10.0, 'suffix:px/s') var shrink_speed := 500.0

@export_group('Trail size')
## If true, this trail is kept with a maximum of [member max_point_count] points in it.
@export var count_criterion := true
## If true, the maximum length for this trail will be enforced to be [member max_length] pixels.
@export var length_criterion := false
## If true, points older than [member max_age] secs will be removed from the trail.
@export var age_criterion := false
## How many points max are enforced to be in the trail, if [member count_criterion] is true.
@export_range(0, 100000, 1) var max_point_count := 100
## The maximum pixel length enforced for the trail, if [member length_criterion] is true.
@export_range(0, 100000, 1, 'suffix:px') var max_length := 150
## The maximum age in seconds for a point in the trail, if [member age_criterion] is true.
@export_range(0.0, 100000.0, 0.1, 'suffix:s') var max_age := 1.0

var _curve : Curve2D
var _timestamps : Array
var _length : float

## Sets whether this trail will be shrinking (i.e., it will reduce its length).
## Works only if [member length_criterion] is true.
func set_shrinking(v: bool) -> void:
	shrinking = v
	
func _ready():
	_curve = Curve2D.new()
	_timestamps = []
	_length = max_length
	
func _process(delta):
	assert(_curve.get_point_count() == _timestamps.size())
	
	# reduce the trail length if not growing
	if shrinking:
		_length = max(0, _length - shrink_speed*delta)
	else:
		_length = max_length
		
	var new_point := compute_new_point()
	
	# add the new point only if it is far enough from the last one
	if _curve.get_point_count() == 0 or new_point.distance_to(_curve.get_point_position(_curve.get_point_count()-1)) > 0.1:
		_curve.add_point(new_point)
		_timestamps.append(Time.get_ticks_msec())
	
	while (count_criterion and _curve.get_point_count() > max_point_count) or (length_criterion and _curve.get_baked_length() > _length) or (age_criterion and _timestamps.size() > 0 and Time.get_ticks_msec()-_timestamps[0] > max_age*1000.0):
		_curve.remove_point(0)
		_timestamps.pop_front()
		
	_redraw()
	
func _redraw() -> void:
	set_points(_curve.get_baked_points())
	
## Returns the new point that this trail has added (or will add) in the current frame.
func compute_new_point() -> Vector2:
	return host.global_position + offset.rotated(host.global_rotation)
	
## Delete all points from this trail.
func clear():
	_curve.clear_points()
	_timestamps.clear()
	clear_points()
