extends Button

class_name FancyButtonGeneric
## A special [TextureButton] that grows and glows when focused.

func _ready():
	focus_mode = Control.FOCUS_NONE
	pivot_offset = size / 2.0
	blur()
	

func focus():
	text = "I'M FOCUSED"
	modulate = Color(1.16, 1.16, 1.16)
	

func blur():
	text = "I'M EMPTY AND ALONE"
	modulate = Color(0.45, 0.45, 0.45)
	
	
	
