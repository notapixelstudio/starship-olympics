extends Control

onready var container = $Container
var ordered_species : Array

func initialize(available_species:Dictionary, controls:Array):
	ordered_species = available_species.keys()
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
	

