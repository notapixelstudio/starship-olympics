extends Sprite
tool

onready var text: String = "" setget _set_command
onready var sprite = $Sprite

func _set_command(value):
	text = value
	$Line2D/Label.text = text

func show_button(event: InputEventJoypadButton):
	sprite.modulate.a = event.pressure + float(event.pressed)
	
