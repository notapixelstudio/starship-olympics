tool
extends Button

export var title: String

signal nav_to

func _process(delta):
	self.text = title.to_upper()
	
func _on_Controls_pressed():
	emit_signal("nav_to", title)
