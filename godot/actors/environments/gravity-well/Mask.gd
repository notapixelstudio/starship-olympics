extends Node2D

var points = PoolVector2Array()

var frame_count: int = -1
onready var outside_wall_shape = (get_node('../../../OutsideWall') as Wall).get_gshape()
onready var light = (get_node('../../Light2D') as Light2D)
onready var viewport = get_node("..")

export var multiplier := 1.1
export var scale_texture := Vector2.ONE
export var frames_wait := 3

func _process(delta):
	frame_count += 1
	if not (light and outside_wall_shape and viewport):
		return
	
	if frame_count % frames_wait:
		return
		
	var offset = original - outside_wall_shape.get_extents()
	points = outside_wall_shape.to_PoolVector2Array_offset((offset+outside_wall_shape.get_extents())/2*multiplier, float(1.0/scale_texture.x))
	light.texture = viewport.get_texture()
	update()

var original = Vector2()
func _ready():
	original = outside_wall_shape.get_extents()
	points = outside_wall_shape.to_PoolVector2Array_offset(outside_wall_shape.get_extents()/2*multiplier, float(1/scale_texture.x))
	light.texture = viewport.get_texture()
	
func _draw():
	draw_colored_polygon(points, Color(1,1,1))
	
