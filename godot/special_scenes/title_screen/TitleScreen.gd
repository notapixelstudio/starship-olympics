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
	print("over")
	can_press = true
	
	
func _ready():
	Soundtrack.play("Lobby5", true)
	initialize()

func _on_Options_pressed():
	animation.play("fade_out")
	yield(animation, "animation_finished")
	emit_signal("option_selected")

	
func _on_StartHuman_pressed():
	if can_press:
		print("we're ready to og")
		emit_signal("start_multiplayer")


func _on_QuitButton_pressed():
	get_tree().quit()
