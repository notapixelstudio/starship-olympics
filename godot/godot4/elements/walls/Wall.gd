@tool
class_name Wall extends StaticBody2D

@export var hollow := false : set = set_hollow
@export var hole : CollisionPolygon2D : set = set_hole

var _polygon : PackedVector2Array

func set_hollow(v: bool) -> void:
	hollow = v
	refresh_shape()
	
func set_hole(v: CollisionPolygon2D) -> void:
	hole = v
	refresh_shape()
	
func refresh_shape() -> void:
	%Polygon2D.visible = not hollow or hole
	%UnderPolygon2D.visible = hollow
	update_navigation()
	
func set_style(style:Style) -> void:
	%Polygon2D.modulate = style.color
	%UnderPolygon2D.modulate = style.background_color
	%UnderPolygon2D.texture = style.background_texture
	%Line2D.default_color = style.line_color
	%Line2D.texture = style.line_texture
	%Line2D.width = style.line_width
	%UnderLine2D.default_color = style.underline_color
	%UnderLine2D.texture = style.underline_texture
	%UnderLine2D.width = style.underline_width
	%GlowLine2D.default_color = style.glow_line_color
	%GlowLine2D.width = style.glow_line_width
	%UnderPolygonOutline2D.default_color = style.grid_color
	%UnderPolygonOutline2D.visible = style.grid_visible
	
func set_polygon(v: PackedVector2Array) -> void:
	_polygon = v
	
	var processed_polygon : PackedVector2Array = _polygon
	if hollow:
		if hole:
			var offset_results = Geometry2D.offset_polygon(_polygon, 100.0)
			if len(offset_results) > 0:
				var hole_removed = Geometry2D.clip_polygons(offset_results[0], hole.get_polygon())
				var clipped = Geometry2D.clip_polygons(hole_removed[0], _polygon)
				if len(clipped) > 0:
					var internal = clipped[0]
					processed_polygon = internal
		else:
			var offset_results = Geometry2D.offset_polygon(_polygon, 100.0)
			if len(offset_results) > 0:
				var clipped = Geometry2D.clip_polygons(offset_results[0], _polygon)
				if len(clipped) > 0:
					var internal = clipped[0] + PackedVector2Array([clipped[1][-1]]) + clipped[1] + PackedVector2Array([clipped[0][-1]])
					processed_polygon = internal
					
	%Polygon2D.set_polygon(processed_polygon)
	%UnderPolygon2D.set_polygon(_polygon)
	%UnderPolygonOutline2D.set_points(_polygon)
	
	if hole:
		%Line2D.set_points(processed_polygon)
		%UnderLine2D.set_points(processed_polygon)
		%GlowLine2D.set_points(processed_polygon)
	else:
		%Line2D.set_points(_polygon)
		%UnderLine2D.set_points(_polygon)
		%GlowLine2D.set_points(_polygon)
	
	_set_collision_polygon(processed_polygon)
	refresh_shape()

# workaround for rapier support: disable and re-enable the collision polygon to force the engine
# this is needed for animated walls for example
func _set_collision_polygon(v: PackedVector2Array) -> void:
	var was_disabled = %CollisionPolygon2D.disabled
	%CollisionPolygon2D.disabled = true
	%CollisionPolygon2D.set_polygon(v)
	%CollisionPolygon2D.disabled = was_disabled

func update_navigation() -> void:
	if not hollow:
		add_to_group("obstacle")
	else:
		remove_from_group("obstacle")
		
func _ready():
	%Styleable.apply_current_style()
	refresh_shape()
