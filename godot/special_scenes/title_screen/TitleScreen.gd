extends Control

signal option_selected
signal entered
signal start_multiplayer

onready var buttons = $Buttons
onready var animation = $Animator

var can_press = false

func initialize():
	animation.stop(true)
	animation.play("fade_in")
	yield(animation, "animation_finished")
	for button in buttons.get_children():
		button.disabled = false
	buttons.get_child(0).grab_focus()
	emit_signal("entered")
	can_press = true
	
func _ready():
	# disable all buttons at first
	for button in buttons.get_children():
		button.disabled = true
	Soundtrack.play("Lobby5", true)
	initialize()

func _on_Options_pressed():
	animation.play("fade_out")
	yield(animation, "animation_finished")
	emit_signal("option_selected")

func _input(event):
	if can_press:
		if event is InputEventKey or event is InputEventJoypadButton: 
			enable_buttons()

	
func enable_buttons():
	can_press = false
	$Buttons.visible = true
	$Description2.visible = false
	$Description2/AnimationPlayer.stop()
	yield(get_tree().create_timer(5), "timeout")
	can_press = true
	for button in $Buttons.get_children():
		button.disabled = false
	
	
func _on_StartHuman_pressed():
	if can_press:
		print("we're ready to og")
		emit_signal("start_multiplayer")


func _on_QuitButton_pressed():
	get_tree().quit()
