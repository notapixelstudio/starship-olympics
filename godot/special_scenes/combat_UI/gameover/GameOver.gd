extends Control

onready var animator = $Animator
onready var leaderboard = $LeaderBoard
onready var buttons = $Buttons
onready var continue_button = $Buttons/Continue

signal pressed_continue
signal back_to_menu
signal show_arena
signal hide_arena

func _ready():
	buttons.visible = false
	
func initialize():
	"""
	Parameters
	----------
	winners : Array of PlayerStats
	
		
	"""
	
	yield(get_tree().create_timer(1), "timeout")
	buttons.visible = true
	var session_over = false
	for player in global.session.players.values():
		assert(player is InfoPlayer)
		session_over = player.get_session_score_total() >= global.win
		
		#TODO: what do we do in case of DRAW of session? Will ignore it for now
		if session_over:
			Soundtrack.play('SessionOver', true)
			continue_button.visible=false
			break
	
	buttons.get_child(int(session_over)).grab_focus()
	
func _on_Continue_pressed():
	emit_signal("pressed_continue")

func _on_Quit_pressed():
	global.end_game()
	#get_tree().quit()

func _on_Menu_pressed():
	# TODO: It will be whoever receive the signal to unpause
	emit_signal("back_to_menu")


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
