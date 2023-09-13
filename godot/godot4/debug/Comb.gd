extends Line2D

## A special type of [Line2D] that erases its oldest points if it gets too long.

## The maximum pixel length enforced for the line.
@export_range(0, 100000, 1, 'suffix:px') var max_length := 6000

var _trajectory_curve : Curve2D
var _comb_curve : Curve2D
var _segments : Array[Array] # of Vector2

func _ready():
	_trajectory_curve = Curve2D.new()
	_comb_curve = Curve2D.new()
	
func _process(delta):
	assert(_trajectory_curve.get_point_count() == _comb_curve.get_point_count())
	
	while _trajectory_curve.get_baked_length() > max_length:
		_trajectory_curve.remove_point(0)
		_comb_curve.remove_point(0)
		_segments.pop_front()
		
	_redraw()
	
func add_points_pair(trajectory_point : Vector2, comb_vector : Vector2):
	# add the new points only if the trajectory point is far enough from the last one
	if _trajectory_curve.get_point_count() == 0 or trajectory_point.distance_to(_trajectory_curve.get_point_position(_trajectory_curve.get_point_count()-1)) > 0.1:
		_trajectory_curve.add_point(trajectory_point)
		_comb_curve.add_point(trajectory_point + comb_vector)
		_segments.append([trajectory_point, trajectory_point + comb_vector])
	
func _redraw() -> void:
	set_points(_comb_curve.get_baked_points())
	queue_redraw()
	
func _draw():
	for i in range(len(_segments)):
		draw_line(_segments[i][0], _segments[i][1], default_color, 1.0, true)
		
