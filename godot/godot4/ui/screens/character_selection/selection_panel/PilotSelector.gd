extends Node2D

class_name PilotSelector

@export var player_id := 'pp': set = set_player_id

signal next(PilotSelector)
signal previous(PilotSelector)
signal ready_selected(PilotSelector)
signal settings_selected(PilotSelector)
signal back_selected(PilotSelector)
signal disconnect_selected(PilotSelector)

var _controls : String = 'none'
var _species : Species
var _status : String

func set_player_id(v: String) -> void:
	player_id = v
	%PPLabel.text = player_id

func set_status(status: String):
	_status = status
	%StatusLabel.text = _status
	%GoMenu.visible = _status == 'selected'
	%GoMenu.set_enabled(_status == 'selected')
	%PilotCharacter.visible = _status != 'disabled'
	%ControlsLabel.visible = _status != 'disabled'
	%SpeciesLabel.visible = _status != 'disabled'
	match status:
		'selected':
			%GoMenu.reset_focused_element()
		'joined':
			%selected.play()
		'disabled':
			%deselected.play()
			%PPLabel.modulate = Color('#7d7d7d')
			
	%PilotCharacter.set_status(_status)
	
func set_controls(controls: String):
	_controls = controls
	%ControlsLabel.text = _controls
	%GoMenu.set_controls(_controls)
	
func get_controls() -> String:
	return _controls

func set_species(species: Species):
	_species = species
	%PPLabel.modulate = _species.get_color()
	%SpeciesLabel.modulate = _species.get_color()
	%SpeciesLabel.text = _species.name
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


func _on_ready_pressed() -> void:
	ready_selected.emit(self)

func _on_settings_pressed() -> void:
	settings_selected.emit(self)

func _on_back_pressed() -> void:
	back_selected.emit(self)

func _on_disconnect_pressed() -> void:
	disconnect_selected.emit(self)
