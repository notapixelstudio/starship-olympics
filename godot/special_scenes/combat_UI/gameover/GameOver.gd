extends Control

onready var animator = $Animator
onready var leaderboard = $LeaderBoard
onready var buttons = $Buttons
onready var back_to_menu_button = $Buttons/Map
onready var continue_button = $Buttons/Continue

signal pressed_continue
signal show_arena
signal hide_arena

var session_over = false

func _ready():
	buttons.visible = false
	global.safe_destroy_match()
	
func initialize():
	"""
	Parameters
	----------
	winners : Array of PlayerStats
	
		
	"""
	
	yield(get_tree().create_timer(1), "timeout")
	buttons.visible = true
	session_over = false
	for player in global.the_game.get_players():
		assert(player is InfoPlayer)
		session_over = player.get_session_score_total() >= global.win
		
		#TODO: what do we do in case of DRAW of session? Will ignore it for now
		if session_over:
			Soundtrack.play('SessionOver', true)
			back_to_menu_button.visible=false
			break
	
	buttons.get_child(int(session_over)).grab_focus()
	
func _on_Continue_pressed():
	get_tree().paused = false
	Events.emit_signal("continue_after_game_over", session_over)

func _on_Quit_pressed():
	global.end_execution()

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


func _on_Map_pressed():
	get_tree().paused = false
	Events.emit_signal("nav_to_map")
