tool
extends TextureButton

export (bool) var locked = false setget locked_planet

signal focus_planet(planet)
signal exit_focus_planet(planet)
signal select_planet(planet)

onready var tween = get_node("Tween")
onready var locked_node = get_node("locked")

func locked_planet(new_value):
	locked = new_value
	disabled = locked
	if locked_node:
		locked_node.visible = locked

func _ready():
	# in order to set the first time
	locked_planet(locked)

func tween_that():
	tween.interpolate_property(self, "rect_scale", rect_scale, rect_scale*1.15,
		1.0, tween.TRANS_BACK, tween.EASE_IN_OUT)
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


func _on_button_navigator_pressed():
	emit_signal("select_planet", name)
