tool
extends TextureButton

signal focus_planet(planet)
signal exit_focus_planet(planet)

func _ready():
	$Label.text = name

func _on_button_navigator_focus_entered():
	if not disabled:
		emit_signal("focus_planet",name)

func _on_button_navigator_focus_exited():
	if not disabled:
		emit_signal("exit_focus_planet",name)
