extends Line2D

## A special type of [Line2D] that automatically erase old points.

## The maximum age in seconds for a point in the trail.
@export_range(0.0, 100000.0, 0.1, 'suffix:s') var max_age := 1.0

var _curve : Curve2D
var _timestamps : Array
var _length : float
	
func _ready():
	_curve = Curve2D.new()
	_timestamps = []
	
func _process(delta):
	assert(_curve.get_point_count() == _timestamps.size())
	
	while _timestamps.size() > 0 and Time.get_ticks_msec()-_timestamps[0] > max_age*1000.0:
		_curve.remove_point(0)
		_timestamps.pop_front()
		
	_redraw()
	
func add_point(new_point : Vector2, index : int = -1):
	assert(index == -1)
	_curve.add_point(new_point)
	_timestamps.append(Time.get_ticks_msec())
	
func _redraw() -> void:
	set_points(_curve.get_baked_points())
	
