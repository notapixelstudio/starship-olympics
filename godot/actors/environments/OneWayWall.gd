tool
extends StaticBody2D

export var width = 600 setget set_width

func set_width(v):
	width = v
	$CollisionShape2D.shape.extents.x = width/2
	$Polygon2D.polygon = PoolVector2Array([
		Vector2(-width/2, -100),
		Vector2(width/2, -100),
		Vector2(width/2-200, 100),
		Vector2(-width/2+200, 100)
	])
	$ShadowPolygon2D.polygon = PoolVector2Array([
		Vector2(-width/2, -100),
		Vector2(width/2, -100),
		Vector2(width/2-200, 100),
		Vector2(-width/2+200, 100)
	])
	
func _ready():
	$ShadowPolygon2D.position = Vector2(0,32).rotated(-global_rotation)
