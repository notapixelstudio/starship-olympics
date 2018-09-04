extends "res://screens/basic_screen.gd"

onready var p1 = $MarginContainer/HBoxContainer/p1
onready var p2 = $MarginContainer/HBoxContainer/p2

func _input(event):
	if event is InputEventMouseButton:
		global.reset()
		change_scene()

func _ready():
	p1.get_node("Player").species = global.species[global.chosen_species["p1"]]
	p2.get_node("Player").species = global.species[global.chosen_species["p2"]]
	for button in $VBoxContainer.get_children():
		button.disabled = true
	
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
			other = player
			win_count = global.scores[player]

	var losing_count = global.scores[other]
	print(losing_count)
	get_node("MarginContainer/HBoxContainer/"+winner).win(win_count)
	get_node("MarginContainer/HBoxContainer/"+other).lose(losing_count)
	var win_species = global.species[global.chosen_species[winner]]

	$MarginContainer/HBoxContainer/Label.text = win_species.to_upper() + " WON!"
	
	yield(get_tree().create_timer(3.0), "timeout")
	
	for button in $VBoxContainer.get_children():
		button.disabled = false
	$VBoxContainer/Rematch.grab_focus()

	# check if we unlocked something
	if global.unlocked == 2 and global.enemy == "CPU":
		global.from_scene = next_scene
		next_scene = "res://screens/special_screen/Unlocked.tscn"
		change_scene()
	global.reset()
	
func _on_Rematch_pressed():
	global.reset()
	change_scene()

func _on_Menu_pressed():
	global.reset()
	get_tree().change_scene_to(load('res://screens/main_screen/main_screen.tscn'))

func _on_Quit_pressed():
	get_tree().quit()
