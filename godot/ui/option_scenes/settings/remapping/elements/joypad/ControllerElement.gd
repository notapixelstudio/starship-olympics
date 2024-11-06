@tool
extends Sprite2D

@onready var text: String = "": set = _set_command
@onready var sprite = $Sprite2D

func _set_command(value):
	text = value
	$Line2D/Label.text = text

func show_button(event: InputEventJoypadButton):
	sprite.modulate.a = event.pressure + float(event.pressed)
	
