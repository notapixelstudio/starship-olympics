extends "res://screens/basic_screen.gd"

func _input(event):
	if event is InputEventMouseButton:
		global.reset()
		change_scene()

func _ready():
	$VBoxContainer/Rematch.grab_focus()
	var winner
	var win_count = 0
	var other 
	for player in global.scores:
		if winner:
			if global.scores[player] > win_count:
				winner = player
				win_count = global.scores[player]
			else:
				other = player
		else:
			winner = player 
			win_count = global.scores[player]

	for player in global.scores:
		if player != winner:
			other = player
	var win_species = global.available_species[global.chosen_species[winner]]
	
	$Sprite.set_texture(load("res://assets/"+win_species+"_win.jpg"))
	$Winner.text = "The winner is " + str(winner) + " with "+ str(win_count) +" - " + str(global.scores[other])+" points "
	
	

func _on_Rematch_pressed():
	global.reset()
	change_scene()


func _on_Menu_pressed():
	global.reset()
	get_tree().change_scene_to(load('res://screens/main_screen/main_screen.tscn'))


func _on_Quit_pressed():
	get_tree().quit()
