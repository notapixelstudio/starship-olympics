extends Line2D

@export var host : Node2D
@export var max_length := 150.0
@export var max_point_count := 10
@export var offset := Vector2(0, 0)

var curve := Curve2D.new()
var length : float

func _ready():
	length = max_length
	
func _process(delta):
	# reduce the flame length if not thrusting
	if not host.is_thrusting():
		length = max(0, length - 500.0*delta)
	else:
		length = max_length
		
	curve.add_point(host.global_position + offset.rotated(host.global_rotation))
	while curve.get_point_count() > max_point_count or curve.get_baked_length() > length:
		curve.remove_point(0)
		
	set_points(curve.get_baked_points())
	
