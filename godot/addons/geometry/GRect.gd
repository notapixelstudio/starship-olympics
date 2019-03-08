extends GPolygon

class_name GRect

export (int) var width = 100 setget set_width, get_width
export (int) var height = 100 setget set_height, get_height

func set_width(value):
	width = value
	_update()
	
func get_width():
	return width

func set_height(value):
	height = value
	_update()
	
func get_height():
	return height

func _update():
	points = PoolVector2Array([Vector2(-width/2,-height/2),Vector2(width/2,-height/2),Vector2(width/2,height/2),Vector2(-width/2,height/2)]) # clockwise!
	