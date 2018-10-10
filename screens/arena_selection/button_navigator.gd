tool
extends Node

export (bool) var locked = 1 setget locked_planed

signal focus_planet(planet)
signal exit_focus_planet(planet)
onready var tween = get_node("Tween")

func locked_planet(new_value):
	locked = new_value
	disabled = locked
	$locked.visible = locked

func _ready():
	$Label.text = name

func tween_that():
	tween.interpolate_property(self, "rect_scale", rect_scale*1.1, rect_scale*1.15,
		1.5, tween.TRANS_BACK, tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rect_scale", rect_scale*1.15, rect_scale*1.1,
		1.5, tween.TRANS_BACK, tween.EASE_IN_OUT, 1.5)
	tween.start()
	yield(tween, "tween_completed")
	
func _on_button_navigator_focus_entered():
	if not disabled:
		tween_that()
		emit_signal("focus_planet",name)

func _on_button_navigator_focus_exited():
	if not disabled:
		tween.stop_all()
		rect_scale = Vector2(1,1)
		emit_signal("exit_focus_planet",name)
