extends Node

onready var animator = $Animator
onready var session = $Session
onready var buttons = $Buttons
onready var continue_button = $Buttons/Continue

signal rematch
signal back_to_menu

func _ready():
	buttons.visible = false
	
func initialize(winners: Array, scores):
	"""
	Parameters
	----------
	winners : Array of PlayerStats
	scores: MatchScores
		
	"""
	
	session.initialize(winners, scores)
	
	yield(get_tree().create_timer(1), "timeout")
	buttons.visible = true
	var session_over = false
	if winners:
		session_over = len(winners[0].session_score) >= global.win
		continue_button.visible = not session_over
	buttons.get_child(int(session_over)).grab_focus()
	
	

func _on_Rematch_pressed():
	print_debug("rematcho")
	emit_signal("rematch")

func _on_Quit_pressed():
	global.end_game()
	#get_tree().quit()

func _on_Menu_pressed():
	# TODO: It will be whoever receive the signal to unpause
	emit_signal("back_to_menu")

func sort_by_score(a, b):
	"""
	Parameters
	----------
	a : InfoPlayer
	b : InfoPlayer
		elements that will be sorted by their current match score
		
	"""
	return len(a.session_score) > len(b.session_score)
