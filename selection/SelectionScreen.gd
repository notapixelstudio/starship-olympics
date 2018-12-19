extends Control

onready var container = $Container
var available_species : Dictionary 
var ordered_species : Array

func initialize(available_species):
	ordered_species = available_species.keys()
	var i = 0
	for child in container.get_children():
		child.change_species(ordered_species[i])
		child.connect("prev", self, "get_previous")
		child.connect("next", self, "get_next")
		i +=1
		
func get_previous(player_selection):
	print(player_selection.species)
	var current_index = ordered_species.find(player_selection.species)
	current_index = global.mod(current_index+1,len(ordered_species))
	player_selection.change_species(ordered_species[current_index])
	
func get_next(player_selection):
	print(player_selection.species)
	print(ordered_species.find(player_selection.species))
