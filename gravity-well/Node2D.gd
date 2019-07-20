extends Node2D

func _process(delta):
	if get_node('../../Light2D') and get_node('..'):
		(get_node('../../Light2D') as Light2D).texture = (get_node('..') as Viewport).get_texture()
		update()
	
func _draw():
	draw_colored_polygon(PoolVector2Array([Vector2(250,250),Vector2(700,250),Vector2(750,300),Vector2(750,750),Vector2(250,750)]), Color(1,1,1))
	