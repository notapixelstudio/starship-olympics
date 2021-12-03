extends CanvasLayer

func _ready():
	scale = global.get_graphics_scale()
	$PanelContainer.rect_size = Vector2(1280, 180)
	$PanelContainer.margin_top = -180
