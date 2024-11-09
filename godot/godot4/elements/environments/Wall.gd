@tool
extends StaticBody2D

@export var hollow := false : set = set_hollow
@export var background_color := Color('#333333') : set = set_background_color

var polygon : PackedVector2Array

func set_hollow(v: bool) -> void:
	hollow = v
	%Polygon2D.visible = not hollow
	%UnderPolygon2D.visible = hollow
	
func set_background_color(v:Color) -> void:
	background_color = v
	%UnderPolygon2D.color = background_color

func set_polygon(v: PackedVector2Array) -> void:
	polygon = v
	%Polygon2D.set_polygon(polygon)
	%Line2D.set_points(polygon)
	%UnderLine2D.set_points(polygon)
	%UnderPolygon2D.set_polygon(polygon)
	update_collision_polygon()
	
func update_collision_polygon() -> void:
	if hollow:
		var offset_results = Geometry2D.offset_polygon(polygon, 100.0)
		if len(offset_results) > 0:
			var clipped = Geometry2D.clip_polygons(offset_results[0], polygon)
			if len(clipped) > 0:
				var internal = clipped[0] + PackedVector2Array([clipped[1][-1]]) + clipped[1] + PackedVector2Array([clipped[0][-1]])
				%CollisionPolygon2D.set_polygon(internal)
	else:
		%CollisionPolygon2D.set_polygon(polygon)
