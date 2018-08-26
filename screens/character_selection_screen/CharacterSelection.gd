extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal random_choice

func _ready():
	if global.enemy == "CPU":
		randomize()
		$MarginContainer/HBoxContainer/P2.disable_choice()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

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
		$Button.disabled = false
		$Button.visible = true
		$Button.grab_focus()

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
	random_choice = randi() % len(global.available_species)
	while(forbidden == random_choice):
		random_choice = randi() % len(global.available_species)
	global.chosen_species[player] = random_choice
	$MarginContainer/HBoxContainer/P2.change_species(global.available_species[random_choice])
	$MarginContainer/HBoxContainer/P2/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/Sprite.set_modulate(Color(1, 1, 1, 1))
	$MarginContainer/HBoxContainer/P2/VBoxContainer/MarginContainer/HBoxContainer/CharacterContainer/SelRect.visible = true

func _on_Button_pressed():
	get_tree().change_scene_to(load("res://screens/game_screen/Game.tscn"))
