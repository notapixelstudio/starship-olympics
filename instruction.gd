# script instructions
extends TextureButton

func _ready():
	connect("pressed", self, "_on_pressed")
	pass
	
func _on_pressed():
	hide()
	pass

