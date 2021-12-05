extends CanvasLayer

func _ready():
	$PanelContainer.rect_scale = global.get_graphics_scale()
	
