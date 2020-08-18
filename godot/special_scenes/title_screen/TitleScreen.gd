extends Control

signal option_selected
signal entered
signal start_multiplayer

onready var animation = $Animator
var can_press = false

func initialize():
	animation.stop(true)
	animation.play("fade_in")
	yield(animation, "animation_finished")
	emit_signal("entered")
	can_press = true
	
	
func _on_Options_pressed():
	animation.play("fade_out")
	yield(animation, "animation_finished")
	emit_signal("option_selected")

	
func _on_StartHuman_pressed():
	if can_press:
		emit_signal("start_multiplayer")

