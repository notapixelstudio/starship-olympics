extends "res://screens/basic_screen.gd"

func _input(event):
	if event is InputEventMouseButton:
		change_scene()

func _ready():
	var winner
	var win_count = 0
	for player in global.scores:
		if winner:
			if global.scores[player] > win_count:
				winner = player
				win_count = global.scores[player]
				
		else:
			winner = player 
			win_count = global.scores[player]
	
	print(winner)
	$winner.set_text("The winner is " + str(winner) + " with "+ str(win_count) +" points ")
	
	