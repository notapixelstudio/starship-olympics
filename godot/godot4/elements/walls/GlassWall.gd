@tool
class_name GlassWall extends Wall

@export var style_override : Style

func set_style(style:Style) -> void:
	super(style)
	
	%Line2D.width = 24
	%UnderLine2D.width = 24
	%GlowLine2D.width = 70
	#%Line2D.texture = style_override.line_texture
