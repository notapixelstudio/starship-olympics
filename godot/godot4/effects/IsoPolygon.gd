@tool
extends Node2D

@export var height := 32.0 : set = set_height
@export var stroke_width := 6.0 : set = set_stroke_width
@export var stroke := Color('#207bff') : set = set_stroke
@export var fill := Color('#207bff') : set = set_fill
@export var show_edges := true : set = set_show_edges
@export var underline_alpha := 0.4 : set = set_underline_alpha

func set_height(v: float) -> void:
	height = v
	%OutLine2D.set_height(height)
	%UnderLine2D.set_height(height)

func set_stroke_width(v: float) -> void:
	stroke_width = v
	%TopLine2D.width = stroke_width
	%OutLine2D.width = stroke_width
	%UnderLine2D.width = stroke_width
	
func set_stroke(v: Color) -> void:
	stroke = v
	%TopLine2D.modulate = stroke
	%OutLine2D.modulate = stroke
	%UnderLine2D.modulate = stroke
	
func set_fill(v: Color) -> void:
	fill = v
	%Polygon2D.modulate = fill
	%FrontPolygon2D.modulate = Color(fill, min(1.0, fill.a + 0.7))
	
func set_show_edges(v: bool) -> void:
	show_edges = v
	%OutLine2D.set_show_edges(show_edges)
	%UnderLine2D.set_show_edges(show_edges)
	
func set_underline_alpha(v: float) -> void:
	underline_alpha = v
	%UnderLine2D.self_modulate = Color(1,1,1, underline_alpha)
	
func set_polygon(polygon : PackedVector2Array) -> void:
	%UnderLine2D.set_points(polygon)
	
	var translated = Transform2D(0, Vector2(0,-height)) * polygon
	%TopLine2D.set_points(translated)
	
	var hull = Geometry2D.convex_hull(polygon + translated)
	%OutLine2D.set_points(hull)
	%Polygon2D.set_polygon(hull)
	
	var front = Geometry2D.clip_polygons(hull, translated)[0]
	%FrontPolygon2D.set_polygon(front)
	
	if show_edges:
		%OutLine2D.set_edge_points(translated)
