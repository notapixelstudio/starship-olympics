extends Sprite2D
@tool

@onready var text: String = "" :
	get:
		return text # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of _set_command
@onready var sprite = $Sprite2D

func _set_command(value):
	text = value
	$Line2D/Label.text = text

func show_button(event: InputEventJoypadButton):
	sprite.modulate.a = event.pressure + float(event.pressed)
	
