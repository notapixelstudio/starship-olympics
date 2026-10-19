@tool
class_name GlassWall extends Wall

@export var style_override : Style

func set_style(style:Style) -> void:
	super(style)
	
	%Line2D.texture = style_override.line_texture
