extends Node

onready var animator = $Animator
onready var session = $Session

signal rematch
signal back_to_menu


func initialize(winner:String, scores:Dictionary, win_points: int = 3):
	var array_scores = scores.values()
	if winner != "noone":
		scores[winner]["session_score"] += 1
	
	array_scores.sort_custom(self, "sort_by_score")
	session.initialize(array_scores, winner, win_points)
	
	var info_winner = array_scores[0]
	if info_winner.session_score >= win_points:
		print_debug(info_winner.species + " won everything")
		$VBoxContainer.get_child(0).visible = false
		$VBoxContainer.get_child(1).grab_focus()
	else:
		$VBoxContainer.get_child(0).grab_focus()
	
	

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
