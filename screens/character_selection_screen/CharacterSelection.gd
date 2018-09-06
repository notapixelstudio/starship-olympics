extends Node2D


signal random_choice
signal all_ready
var ready = false
onready var p2 = $MarginContainer/HBoxContainer/P2
onready var p1 = $MarginContainer/HBoxContainer/P1

func _ready():
	if global.enemy == "CPU":
		randomize()
		p2.disable_choice()
		p2.controls_label.text = 'CPU'
		p2.controls_container.visible = false


func _input(event):
	if event.is_action_pressed("ui_back"):
		get_tree().change_scene(global.from_scene)
		
func ready_to_fight():
	var n_characters = int(len(global.unlocked_species))
	if not ready:
		if global.enemy == "CPU" :
			emit_signal("random_choice","p2")
		else:
			for p in $MarginContainer/HBoxContainer.get_children():
				if p.is_in_group("choice"):
					if not p.selected:
						ready = false
						var p_name = p.name.to_lower()
						# check if the current selection is still available 
						if global.available_species.find(p.index_selection)== -1 :
							p.index_selection = (p.index_selection + 1) % len(global.available_species)
							p.change_species(global.available_species[p.index_selection])
						break
					else:
						emit_signal("all_ready")
	else:
		$MarginContainer/HBoxContainer/VS.text = "Ready to fight"
		$Button.visible = true
		$Button.grab_focus()
		# workaround for the selection shortcut button
		yield(get_tree().create_timer(0.4), "timeout")
		$Button.disabled = false
		

func _on_P1_selected():
	p1.character_container.selected()
	ready_to_fight()


func _on_P2_selected():
	p2.character_container.selected()
	ready_to_fight()

# Set chosen_species and start random
func _on_Selection_random_choice(player):
	var forbidden 
	for p in global.chosen_species:
		if p != player:
			# get index of chosen_species
			forbidden = global.unlocked_species.find(global.chosen_species[p])
	
	var random_choice = 0
	random_choice = randi() % len(global.species)
	while(forbidden == random_choice or random_choice>=len(global.unlocked_species)):
		random_choice = (random_choice+ 1) % len(global.species)
	global.chosen_species[player] = global.unlocked_species[random_choice]
	simulate_choice(random_choice)
	

# when simulating choice... show all the characters (needs to be blank or offuscate for locked ones)
func simulate_choice(final_choice):
	var how_many_times =8 + randi()%3
	var n_characters = int(len(global.unlocked_species))
	for times in range(0,how_many_times):
		for i in range(0,n_characters):
			var wait_time = 0.1 + 0.01*times
			yield(get_tree().create_timer(wait_time), "timeout")
			# you should cycle around the unlocked_species
			p2.change_species(global.unlocked_species[(i+final_choice)%n_characters])
	yield(get_tree().create_timer(0.5), "timeout")
	p2.change_species(global.unlocked_species[final_choice])
	p2.character_container.selected()
	emit_signal("all_ready")
	
func _on_Button_pressed():
	get_tree().change_scene_to(load("res://screens/game_screen/Game.tscn"))

func _on_Selection_all_ready():
	ready = true
	ready_to_fight()
