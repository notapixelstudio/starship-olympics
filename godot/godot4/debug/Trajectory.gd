extends Line2D

## A special type of [Line2D] that erases its oldest points if it gets too long.

## The maximum pixel length enforced for the line.
@export_range(0, 100000, 1, 'suffix:px') var max_length := 6000
@export var auto := true

var _curve : Curve2D
	
func _ready():
	_curve = Curve2D.new()
	
func _process(delta):
	while _curve.get_baked_length() > max_length:
		_curve.remove_point(0)
		
	if auto and get_parent():
		self.add_point(get_parent().global_position)
	_redraw()
	
func add_point(new_point : Vector2, index : int = -1):
	assert(index == -1)
	
	# add the new point only if it is far enough from the last one
	if _curve.get_point_count() == 0 or new_point.distance_to(_curve.get_point_position(_curve.get_point_count()-1)) > 0.1:
		_curve.add_point(new_point)
	
func _redraw() -> void:
	set_points(_curve.get_baked_points())
	
