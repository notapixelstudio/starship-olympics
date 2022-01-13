tool
extends Button

class_name NavigatorButton

export var option_menu: PackedScene
export var title: String
export var extra_args: String

signal request_nav_to #asking to Session container to nav through


func _process(delta):
	self.text = tr(title.to_upper())
	
func _on_Controls_pressed():
	emit_signal("request_nav_to", title, option_menu, extra_args)
