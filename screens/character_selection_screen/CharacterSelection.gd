extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal random_choice
signal all_ready
var ready = false


func _ready():
	if global.enemy == "CPU":
		randomize()
		$MarginContainer/HBoxContainer/P2.disable_choice()
		$MarginContainer/HBoxContainer/P2/VBoxContainer/Controls/Label.text = 'CPU'
		$MarginContainer/HBoxContainer/P2/VBoxContainer/Controls/CenterContainer.visible = false


func ready_to_fight():
	if not ready:
		if global.enemy == "CPU" :
			emit_signal("random_choice","p2")
		else:
			for p in $MarginContainer/HBoxContainer.get_children():
				if p.is_in_group("choice"):
					if not p.selected:
						ready = false
						break
	else:
		$MarginContainer/HBoxContainer/VS.text = "Ready to fight"
		$Button.visible = true
		$Button.grab_focus()
		# workaround for the selection shortcut button
		yield(get_tree().create_timer(0.4), "timeout")
		$Button.disabled = false
		

func _on_P1_selected():
	$MarginContainer/HBoxContainer/P1/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite.set_modulate(Color(1, 1, 1, 1))
	$MarginContainer/HBoxContainer/P1/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/SelRect.visible = true
	ready_to_fight()


func _on_P2_selected():
	$MarginContainer/HBoxContainer/P2/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite.set_modulate(Color(1, 1, 1, 1))
	$MarginContainer/HBoxContainer/P2/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/SelRect.visible = true
	ready_to_fight()


func _on_Selection_random_choice(player):
	var forbidden 
	for p in global.chosen_species:
		if p != player:
			forbidden = global.chosen_species[p]
	var random_choice = 0
	random_choice = randi() % len(global.species)
	while(forbidden == random_choice or random_choice>=global.unlocked):
		random_choice = (random_choice+ 1) % len(global.species)
	global.chosen_species[player] = random_choice
	simulate_choice(random_choice)
	


func simulate_choice(final_choice):
	var how_many_times =8 + randi()%3
	var n_characters = int(global.unlocked)
	for times in range(0,how_many_times):
		for i in range(0,n_characters):
			var wait_time = 0.1 + 0.01*times
			yield(get_tree().create_timer(wait_time), "timeout")
			$MarginContainer/HBoxContainer/P2.change_species(global.species[(i+final_choice)%n_characters])
	yield(get_tree().create_timer(0.5), "timeout")
	$MarginContainer/HBoxContainer/P2.change_species(global.species[final_choice])
	$MarginContainer/HBoxContainer/P2/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite.set_modulate(Color(1, 1, 1, 1))
	$MarginContainer/HBoxContainer/P2/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/SelRect.visible = true
	emit_signal("all_ready")
	
func _on_Button_pressed():
	get_tree().change_scene_to(load("res://screens/game_screen/Game.tscn"))


func _on_Selection_all_ready():
	ready = true
	ready_to_fight()
