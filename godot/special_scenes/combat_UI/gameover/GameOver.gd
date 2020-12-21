extends Control

onready var animator = $Animator
onready var session = $Session
onready var buttons = $Buttons
onready var continue_button = $Buttons/Continue

signal rematch
signal back_to_menu
signal show_arena
signal hide_arena

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
		if session_over:
			Soundtrack.play('SessionOver', true)
	buttons.get_child(int(session_over)).grab_focus()
	
	

func _on_Rematch_pressed():
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

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		self.visible = true
		emit_signal("hide_arena")
		yield(get_tree().create_timer(0.5), "timeout")
		# grab focus on first button visible
		for button in buttons.get_children():
			if button.visible:
				button.grab_focus()
				break

func _show_arena():
	self.visible = false
	emit_signal("show_arena")
