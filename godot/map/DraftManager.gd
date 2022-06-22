extends Node

func _ready():
	Events.connect('continue_after_game_over', self, '_on_continue_after_game_over')
	
	global.new_session()
	var hand = global.session.get_hand()

func _on_continue_after_game_over(session_ended):
	if not session_ended:
		pick_next_card()
	else:
		pass # end of session -> new card etc
		
func pick_next_minigame():
	var picked_card = global.session.choose_next_card()
	yield(get_tree().create_timer(1), "timeout")
	
func pick_next_card():
	pass
