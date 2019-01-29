tool

extends "res://actors/environments/Wall.gd"

export (int) var width = 200 setget set_width
export (int) var height = 200 setget set_height
export (int) var bevel = 50 setget set_bevel


func set_width(w):
	width = w
	whb2pts()
	
func set_height(h):
	height = h
	whb2pts()
	
func set_bevel(b):
	bevel = b
	whb2pts()
	
func whb2pts():
	set_points(PoolVector2Array([
		Vector2(-width/2,-height/2+bevel),
		Vector2(-width/2+bevel,-height/2),
		Vector2(width/2-bevel,-height/2),
		Vector2(width/2,-height/2+bevel),
		Vector2(width/2,height/2-bevel),
		Vector2(width/2-bevel,height/2),
		Vector2(-width/2+bevel,height/2),
		Vector2(-width/2,height/2-bevel)
	])) # clockwise!
	