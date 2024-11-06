extends Node2D

class_name PilotSelector

@export var player_id := 'pp': set = set_player_id

func set_player_id(v: String) -> void:
	player_id = v
	$Label.text = player_id

func set_status(status: String):
	$Label3.text = status

func set_controls(controls: String):
	$Label2.text = controls
	%FancyMenuWithSingularControl.set_controls(controls)

func set_species(species: Species):
	$Label4.text = species.name
