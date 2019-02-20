extends Node

signal started()
signal finished()

onready var transition = $Overlays/TransitionColor
onready var buttons = $Buttons
var transitioning = false

func _ready():
	for button in buttons.get_children():
		button.disabled = false
	buttons.get_child(0).grab_focus()
	switch()


func switch():
	if transitioning:
		return

	transitioning = true
	# initialize whatever scene
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	
