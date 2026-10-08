extends Node2D

func _ready():
	$Styleable.apply_current_style()
	
func set_style(style:Style) -> void:
	modulate = style.underline_color
