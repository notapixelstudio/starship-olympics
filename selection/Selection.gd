extends Control

var n_players = 0

signal random_choice
signal all_ready

var ready = false
onready var players = get_node("players_containers")
onready var ready_screen = get_node("CanvasLayer/ReadyScreen")

var p2
var fire_buttons = []

func _ready():
	randomize()

	for button in InputMap.get_actions():
		if "fire" in button:
			fire_buttons.append(button)
	
	# get how many controllers are attached
	var joypads  = Input.get_connected_joypads()
	for player in players.get_children() :
		#connect the ready for fight signal
		player.connect("selected", self, "_on_player_select", [player.name])
		player.connect("deselected", self, "_on_player_deselect", [player.name])
		player.connect("leave", self, "_on_player_leaves", [player.name])
		player.connect("ready_to_fight", self, "ready_to_fight")
		player.disable_choice()
		
func ready_to_fight():
	# emit something to make undestand that you can play
	if n_players >=2:
		get_tree().paused = true
		ready_screen.ready_to_fight(n_players)
		ready_screen.visible = true
		ready_screen.get_node("Choose_container").get_child(0).grab_focus()
		
	
func _gui_input(event):
	for button in fire_buttons:
		if event.is_action_pressed(button):
			for player in players.get_children():
				if not player.joined:
					fire_buttons.remove(fire_buttons.find(button))
					player.set_commands(button)
					break
					
	if event.is_action_pressed("ui_cancel"):
		var can_change = true
		for player in players.get_children():
			if player.joined:
				can_change = false
				break
		if can_change:
			get_tree().change_scene(global.from_scene)					
					
		
func _on_player_leaves(player):
	# need to add the control back
	fire_buttons.append(global.controls[player.to_lower()]+"_fire")
	
func _on_player_select(player):
	n_players += 1
	ready_to_fight()

func _on_player_deselect(player):
	n_players -= 1
	ready_to_fight()

# Set chosen_species and start random
func _on_Selection_random_choice(player):
	"""
	
	"""
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
	var how_many_times = 10
	var n_characters = int(len(global.unlocked_species))
	for times in range(0,how_many_times):
		var wait_time = 0.1 + 0.01*times
		yield(get_tree().create_timer(wait_time), "timeout")
		# you should cycle around the unlocked_species
		p2.change_species(global.unlocked_species[(times+final_choice)%n_characters])
	yield(get_tree().create_timer(0.5), "timeout")
	p2.change_species(global.unlocked_species[final_choice])
	emit_signal("all_ready")

func _on_Selection_all_ready():
	ready = true
	ready_to_fight()

