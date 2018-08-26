extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal random_choice

func _ready():
	if global.enemy == "CPU":
		randomize()
		$MarginContainer/HBoxContainer/P2.disable_choice()
		$MarginContainer/HBoxContainer/P2/VBoxContainer/Controls/Label.text = 'CPU'
		$MarginContainer/HBoxContainer/P2/VBoxContainer/Controls/CenterContainer.visible = false


func ready_to_fight():
	var ready = true
	if global.enemy == "CPU":
		emit_signal("random_choice","p2")
		ready = true
		
	else:
		for p in $MarginContainer/HBoxContainer.get_children():
			if p.is_in_group("choice"):
				if not p.selected:
					ready = false
					break
	if ready:
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
		random_choice += 1 % len(global.species)
	global.chosen_species[player] = random_choice
	simulate_choice()
	$MarginContainer/HBoxContainer/P2.change_species(global.species[random_choice])
	$MarginContainer/HBoxContainer/P2/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite.set_modulate(Color(1, 1, 1, 1))
	$MarginContainer/HBoxContainer/P2/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/SelRect.visible = true


func simulate_choice():
	var how_many_times = randi() % 10
	var n_characters = global.unlocked
	for times in range(0,how_many_times):
		for i in range(0,n_characters):
			yield(get_tree().create_timer(0.1), "timeout")
			$MarginContainer/HBoxContainer/P2.change_species(global.species[i])

func _on_Button_pressed():
	get_tree().change_scene_to(load("res://screens/game_screen/Game.tscn"))
