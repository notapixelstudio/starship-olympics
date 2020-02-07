extends Node

onready var animator = $Animator
onready var session = $Session

signal rematch
signal back_to_menu


func initialize(winners: Array, scores: MatchScores):
	"""
	Parameters
	----------
	winners : Array of PlayerStats
		
	"""
	
	session.initialize(winners, scores)
	
	yield(get_tree().create_timer(1), "timeout")
	
	

func _on_Rematch_pressed():
	print_debug("rematcho")
	emit_signal("rematch")

func _on_Quit_pressed():
	global.end_game()
	#get_tree().quit()

func _on_Menu_pressed():
	# TODO: It will be whoever receive the signal to unpause
	emit_signal("back_to_menu")

func sort_by_score(a: InfoPlayer, b: InfoPlayer):
	return a.session_score > b.session_score
