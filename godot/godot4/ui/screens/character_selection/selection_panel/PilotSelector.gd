extends Node2D

class_name PilotSelector

@export var player_id := 'pp': set = set_player_id

var _controls : String
var _species : Species
var _status : String

func set_player_id(v: String) -> void:
	player_id = v
	$Label.text = player_id

func set_status(status: String):
	_status = status
	$Label3.text = _status

func set_controls(controls: String):
	_controls = controls
	$Label2.text = _controls
	%FancyMenuWithSingularControl.set_controls(_controls)

func set_species(species: Species):
	_species = species
	$Label4.text = _species.name

func is_status(check:String) -> bool:
	return _status == check
	
func get_player_data() -> Player:
	var p = Player.new()
	p.set_id(player_id)
	p.set_controls(_controls)
	p.set_species(_species)
	
	return p
