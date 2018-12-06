extends Node

signal started()
signal finished()

onready var transition = $Overlays/TransitionColor

var transitioning = false
func _ready():
	pass


func switch():
	"""
	
	"""
	if transitioning:
		return
		
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	# initialize whatever scene
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	emit_signal("started")
	# Get data from the battlers after the battle ended,
	# Then copy into the Party node to save earned experience,
	# items, and currentstats
	emit_signal("finished")
	transitioning = true
	yield(transition.fade_to_color(), "completed")
	yield(transition.fade_from_color(), "completed")
	transitioning = false
