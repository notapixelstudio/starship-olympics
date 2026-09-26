@tool
class_name Ice extends Area2D

var _polygon : PackedVector2Array

func set_polygon(v: PackedVector2Array) -> void:
	_polygon = v
	%CollisionPolygon2D.polygon = _polygon
	%Polygon2D.polygon = _polygon
