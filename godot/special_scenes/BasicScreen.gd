extends Node
class_name BasicScreen

signal started()
signal finished()

onready var transition = $Overlays/TransitionColor
onready var buttons = $Buttons
var transitioning = false

func _ready():
	
	switch()


func switch():
	if transitioning:
		return

	transitioning = true
	# initialize whatever scene
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	
