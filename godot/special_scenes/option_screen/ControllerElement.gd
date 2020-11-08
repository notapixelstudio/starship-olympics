extends Sprite
tool

onready var text: String = "" setget _set_command

func _set_command(value):
	text = value
	$Line2D/Label.text = text
