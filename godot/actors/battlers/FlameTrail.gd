extends Line2D

@export var max_length := 150.0
@export var max_point_count := 10
var host : Node2D
var curve := Curve2D.new()

func _ready():
	host = get_parent()

func _process(delta):
	curve.add_point(host.global_position)
	while curve.get_point_count() > max_point_count or curve.get_baked_length() > max_length:
		curve.remove_point(0)
		
	set_points(curve.get_baked_points())
	
