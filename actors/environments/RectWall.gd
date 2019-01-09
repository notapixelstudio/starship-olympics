tool

extends Wall

export (int) var width = 200 setget set_width
export (int) var height = 200 setget set_height

func set_width(w):
	width = w
	wh2pts()
	
func set_height(h):
	height = h
	wh2pts()
	
func wh2pts():
	set_points(PoolVector2Array([Vector2(-width/2,-height/2),Vector2(width/2,-height/2),Vector2(width/2,height/2),Vector2(-width/2,height/2)])) # clockwise!
	