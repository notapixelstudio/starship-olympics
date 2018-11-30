extends Node

signal combat_started()
signal combat_finished()

onready var transition = $Overlays/TransitionColor
onready var local_map = $LocalMap

var transitioning = false
func _ready():
	start()
func start():
	"""
	
	"""
	if transitioning:
		return
		
	transitioning = true
	yield(transition.fade_to_color(), "completed")


	# initialize whatever scene
	yield(transition.fade_from_color(), "completed")
	transitioning = false
	
	emit_signal("combat_started")
	
	# Get data from the battlers after the battle ended,
	# Then copy into the Party node to save earned experience,
	# items, and currentstats

	emit_signal("combat_finished")
	transitioning = true
	yield(transition.fade_to_color(), "completed")

	yield(transition.fade_from_color(), "completed")
	transitioning = false
