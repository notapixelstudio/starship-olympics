extends Control

onready var container = $Container
var ordered_species : Array

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

var players_controls : Array
var num_players : int
func initialize(available_species:Dictionary, controls:Array):
	ordered_species = available_species.keys()
	var joypads = Input.get_connected_joypads()
	
	for i in range(0,4):
		if len(joypads) > i:
			num_players += 1
			players_controls.append("joy"+str(i))
	if num_players < 2:
		num_players += 1
		players_controls.push_front("kb1")
	for i in range(0, 4-num_players):
		players_controls.append("no")
		
	controls = players_controls
	var i = 0
	for child in container.get_children():
		child.change_species(ordered_species[i])
		child.set_controls_by_string(controls[i])
		child.connect("prev", self, "get_adjacent", [-1, child])
		child.connect("next", self, "get_adjacent", [+1, child])
		i +=1
		
func get_adjacent(operator:int, player_selection : Node):
	var current_index = ordered_species.find(player_selection.species) 
	current_index = global.mod(current_index + operator,len(ordered_species))
	player_selection.change_species(ordered_species[current_index])
	
func _on_joy_connection_changed(device_id, connected):
    if connected:
        print(Input.get_joy_name(device_id))
    else:
        print("Keyboard")
