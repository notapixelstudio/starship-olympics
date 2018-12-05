extends Control

onready var ship = $Ship
onready var tween = $Tween
onready var species_name = $SpeciesName

func previous():
	global.shake_node(species_name, tween)
	
func next():
	global.shake_node(species_name, tween)
	