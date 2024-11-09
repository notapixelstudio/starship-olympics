extends Node2D

var points = PackedVector2Array()

var frame_count: int = -1


@export var shape_node : VParametricShape

@export var multiplier := 1.1
@export var scale_texture := Vector2.ONE
@export var frames_wait := 3

func _process(delta):
	frame_count += 1
	if not shape_node:
		return
	
	if frame_count % frames_wait: # FIXME check this optimization
		return
		
	#var offset = original - outside_wall_shape.get_extents()
	#points = outside_wall_shape.to_PoolVector2Array_offset((offset+outside_wall_shape.get_extents())/2*multiplier, float(1.0/scale_texture.x))
	points = shape_node.get_points()
	queue_redraw()

var original = Vector2()
func _ready():
	#original = outside_wall_shape.get_extents()
	#points = outside_wall_shape.to_PoolVector2Array_offset(outside_wall_shape.get_extents()/2*multiplier, float(1/scale_texture.x))
	pass
	
func _draw():
	draw_colored_polygon(points, Color(1,1,1))
	
