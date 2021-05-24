tool

extends Area2D
class_name Glue

export var width = 200 setget set_width
export var depth = 100 setget set_depth
export var half_angle = PI*0.6

func set_width(v):
	width = v
	refresh_size()
	
func set_depth(v):
	depth = v
	refresh_size()
	
func _ready():
	refresh_size()
	
func refresh_size():
	var points = [
		Vector2(-depth,-width/2),
		Vector2(50,-width/2),
		Vector2(100,-width/2+50),
		Vector2(100,width/2-50),
		Vector2(50,width/2),
		Vector2(-depth,width/2)
	]
	$Polygon2D.polygon = PoolVector2Array(points)
	$CollisionPolygon2D.polygon = PoolVector2Array(points)
	$Line2D.points = PoolVector2Array(points)

func get_half_angle():
	return half_angle
