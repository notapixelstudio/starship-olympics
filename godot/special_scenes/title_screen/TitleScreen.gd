extends Control

signal option_selected
signal entered

onready var buttons = $Buttons
onready var animation = $Animator

func initialize():
	animation.stop(true)
	animation.play("fade_in")
	yield(animation, "animation_finished")
	for button in buttons.get_children():
		button.disabled = false
	buttons.get_child(0).grab_focus()
	emit_signal("entered")
	
func _ready():
	Soundtrack.play("Lobby4", true)
	initialize()

func _on_Options_pressed():
	animation.play("fade_out")
	yield(animation, "animation_finished")
	emit_signal("option_selected")
