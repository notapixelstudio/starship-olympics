extends Node
class_name BasicScreen

signal started()
signal finished()

onready var transition = $Overlays/TransitionColor
var transitioning = false


func switch():
	if transitioning:
		return
	transitioning = true
	# initialize whatever scene
	yield(transition.fade_to_color(), "completed")
	transitioning = false
	emit_signal("finished")
	
