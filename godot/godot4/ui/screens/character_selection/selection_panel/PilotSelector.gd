extends Node2D

class_name PilotSelector

@export var player_id := 'pp': set = set_player_id

signal next(PilotSelector)
signal previous(PilotSelector)

var _controls : String = 'none'
var _species : Species
var _status : String

func set_player_id(v: String) -> void:
	player_id = v
	$Label.text = player_id

func set_status(status: String):
	_status = status
	$Label3.text = _status
	%ReadyMenu.visible = _status == 'joined'
	%GoMenu.visible = _status == 'selected'
	%PilotCharacter.visible = _status != 'disabled'
	match status:
		'joined':
			%selected.play()
		'disabled':
			%deselected.play()
	
func set_controls(controls: String):
	_controls = controls
	$Label2.text = _controls
	%ReadyMenu.set_controls(_controls)
	%GoMenu.set_controls(_controls)

func set_species(species: Species):
	_species = species
	$Label4.text = _species.name
	%ReadyMenu.set_tint(_species.get_color())
	%GoMenu.set_tint(_species.get_color())
	%PilotCharacter.set_species(_species)

func is_status(check:String) -> bool:
	return _status == check
	
func get_player_data() -> Player:
	var p = Player.new()
	p.set_id(player_id)
	p.set_controls(_controls)
	p.set_species(_species)
	
	return p

var ignore := true
func _process(delta):
	if _controls == 'none' or _status == 'disabled':
		return
		
	if not ignore and Utils.is_action_strong(_controls+"_right"):
		ignore = true
		%"switch-selection".play()
		next.emit(self)
	elif not ignore and Utils.is_action_strong(_controls+"_left"):
		ignore = true
		%"switch-selection".play()
		previous.emit(self)
	elif Utils.are_controls_at_rest(_controls):
		ignore = false
