@tool
extends StaticBody2D

@export var hollow := false : set = set_hollow

var polygon : PackedVector2Array

func set_hollow(v: bool) -> void:
	hollow = v
	%Polygon2D.visible = not hollow
	%UnderPolygon2D.visible = hollow
	update_navigation()
	
func set_style(style:Style) -> void:
	%Polygon2D.modulate = style.color
	%UnderPolygon2D.modulate = style.background_color
	%Line2D.default_color = style.line_color
	%Line2D.texture = style.line_texture
	%Line2D.width = style.line_width
	%UnderLine2D.default_color = style.underline_color
	%UnderLine2D.texture = style.underline_texture
	%UnderLine2D.width = style.underline_width
	
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

func update_navigation() -> void:
	if not hollow:
		add_to_group("obstacle")
	else:
		remove_from_group("obstacle")
		
func _ready():
	var style = %Styleable.get_style_from_ancestor_or_self()
	if style:
		set_style(style)
