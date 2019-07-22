extends Node2D

var points = PoolVector2Array()

var frame_count: int = -1
onready var outside_wall_shape = (get_node('../../../OutsideWall') as Wall).get_gshape()
onready var light = (get_node('../../Light2D') as Light2D)
onready var viewport = get_node("..")
func _process(delta):
	frame_count += 1
	if not (light and outside_wall_shape and viewport):
		return
	
	if frame_count % 3:
		return
	
	points = outside_wall_shape.to_PoolVector2Array_offset(outside_wall_shape.get_extents()/2*1.1, 0.03125)
	light.texture = viewport.get_texture()
		
	update()

func _ready():
	points = outside_wall_shape.to_PoolVector2Array_offset(outside_wall_shape.get_extents()/2*1.1, 0.03125)
	light.texture = viewport.get_texture()
	
func _draw():
	draw_colored_polygon(points, Color(1,1,1))
	