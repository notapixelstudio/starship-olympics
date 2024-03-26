@tool
extends StaticBody2D

@export var width = 600: set = set_width

func set_width(v):
	width = v
	$CollisionShape2D.shape.size.x = width/2
	$Polygon2D.polygon = PackedVector2Array([
		Vector2(-width/2, -100),
		Vector2(width/2, -100),
		Vector2(width/2-200, 100),
		Vector2(-width/2+200, 100)
	])
	$ShadowPolygon2D.polygon = PackedVector2Array([
		Vector2(-width/2, -100),
		Vector2(width/2, -100),
		Vector2(width/2-200, 100),
		Vector2(-width/2+200, 100)
	])
	
func _ready():
	$ShadowPolygon2D.position = Vector2(0,32).rotated(-global_rotation)
