@tool
extends Node2D

@export var height := 32.0


func set_polygon(polygon : PackedVector2Array) -> void:
	%UnderLine2D.set_points(polygon)
	
	var translated = Transform2D(0, Vector2(0,-height)) * polygon
	%TopLine2D.set_points(translated)
	
	var hull = Geometry2D.convex_hull(polygon + translated)
	%OutLine2D.set_points(hull)
	%Polygon2D.set_polygon(hull)
	
	var front = Geometry2D.clip_polygons(hull, translated)[0]
	%IsoPolygon2D.set_polygon(front)
