extends Node

signal started()
signal finished()

onready var transition = $Overlays/TransitionColor

var transitioning = false
func _ready():
	switch()


func switch():
	if transitioning:
		return
		
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	# initialize whatever scene
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	emit_signal("started")
	emit_signal("finished")
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	yield(transition.fade_from_color(), "completed")
	transitioning = false
