@tool
extends Node2D

@export var height := 32.0
@export var stroke := Color('#207bff') : set = set_stroke
@export var fill := Color('#207bff') : set = set_fill

func set_stroke(v: Color) -> void:
	stroke = v
	%TopLine2D.modulate = stroke
	%OutLine2D.modulate = stroke
	%UnderLine2D.modulate = stroke
	
func set_fill(v: Color) -> void:
	fill = v
	%Polygon2D.modulate = fill
	%FrontPolygon2D.modulate = fill

func set_polygon(polygon : PackedVector2Array) -> void:
	%UnderLine2D.set_points(polygon)
	
	var translated = Transform2D(0, Vector2(0,-height)) * polygon
	%TopLine2D.set_points(translated)
	
	var hull = Geometry2D.convex_hull(polygon + translated)
	%OutLine2D.set_points(hull)
	%Polygon2D.set_polygon(hull)
	
	var front = Geometry2D.clip_polygons(hull, translated)[0]
	%FrontPolygon2D.set_polygon(front)
