tool
extends Node2D

export var text : String = '' setget set_text
export var shear : Vector2 = Vector2(0,0) setget set_shear
export (String, 'left', 'center', 'right') var align = 'center' setget set_align

func set_text(v: String) -> void:
	text = v
	$'%Label'.text = text

func set_shear(v: Vector2) -> void:
	shear = v
	$Wrapper.transform.y.x = shear.x
	$Wrapper.transform.x.y = shear.y
	
func set_align(v: String) -> void:
	align = v
	match align:
		'left':
			$Wrapper/Label.align = Label.ALIGN_LEFT
			$Wrapper/Label.rect_position.x = 0
		'center':
			$Wrapper/Label.align = Label.ALIGN_CENTER
			$Wrapper/Label.rect_position.x = -300
		'right':
			$Wrapper/Label.align = Label.ALIGN_RIGHT
			$Wrapper/Label.rect_position.x = -600
			
