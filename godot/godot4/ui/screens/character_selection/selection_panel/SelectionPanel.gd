extends Control

signal selection_completed

@export var min_players := 2
@export var ready_to_fight: PackedScene

var relevant_actions := {}
var mapping_controls_pilot := {}
var mapping_pilot_displayed_species := {}
var mapping_pilot_claimed := {}
var available_species : Array[Species] = []
var _touch_fire_down := {}
const TOUCH_CONTROLS := "rm1"

func _ready():
	available_species = Species.get_all_unlocked()
	for action in InputMap.get_actions():
		for action_name in ["_fire", "_left", "_right", "_up", "_down"]:
			if action_name in action and not "ui" in action: 
				relevant_actions[action] = (InputMap.action_get_events(action))

	Utils.touch_fire.connect(_on_touch_fire)

	if has_node("TouchUI"):
		$TouchUI.prev_pressed.connect(_on_touch_prev)
		$TouchUI.next_pressed.connect(_on_touch_next)
		$TouchUI.action_pressed.connect(_on_touch_action)
				
	for child in get_children():
		if child is not PilotSelector:
			continue
		child.next.connect(_on_pilot_selector_next)
		child.previous.connect(_on_pilot_selector_previous)
		child.ready_selected.connect(_on_pilot_ready_selected)
		child.back_selected.connect(_on_pilot_back_selected)
		child.disconnect_selected.connect(_on_pilot_disconnect_selected)

	_update_touch_ui()
		
func _get_action_from_event(event: InputEvent):
	if event is InputEventAction and (event.action as String) in relevant_actions:
		return event.action
	for action in relevant_actions:
		if InputMap.event_is_action(event, action):
			return action
	return null

func _on_touch_fire(controls: String, pressed: bool) -> void:
	if pressed:
		_handle_control_action(controls, "fire")

func _on_touch_prev() -> void:
	_browse_touch_pilot(-1)

func _on_touch_next() -> void:
	_browse_touch_pilot(1)

func _on_touch_action() -> void:
	_handle_control_action(TOUCH_CONTROLS, "fire")
	
func _input(event: InputEvent):
	if not event.is_pressed():
		return
		
	var action = _get_action_from_event(event)
	if action == null:
		return
	
	var controls = (action as String).split("_")[0]
	var action_suffix = (action as String).split("_")[1]
	_handle_control_action(controls, action_suffix)

func _process(_delta: float) -> void:
	if not is_processing_input():
		return
	for prefix in ["rm1", "rm2", "rm3", "rm4"]:
		var action: String = prefix + "_fire"
		if not InputMap.has_action(action):
			continue
		var down := Input.is_action_pressed(action)
		if down and not _touch_fire_down.get(prefix, false):
			_handle_control_action(prefix, "fire")
		_touch_fire_down[prefix] = down

func _browse_touch_pilot(direction: int) -> void:
	if not TOUCH_CONTROLS in mapping_controls_pilot:
		return
	var pilot_selector: PilotSelector = mapping_controls_pilot[TOUCH_CONTROLS]
	if direction > 0:
		_on_pilot_selector_next(pilot_selector)
	else:
		_on_pilot_selector_previous(pilot_selector)

func _handle_control_action(controls: String, action_suffix: String) -> void:
	if controls in mapping_controls_pilot:
		var pilot_selector : PilotSelector = mapping_controls_pilot[controls]
		match action_suffix:
			'fire':
				if not pilot_selector in mapping_pilot_claimed:
					_claim_displayed_species(pilot_selector)
					pilot_selector.set_status('selected')
					if len(mapping_pilot_claimed) >= min_players:
						%Label.text = "{players} READY".format({"players":len(mapping_pilot_claimed)})
					else: 
						%Label.text = "Not enough players. {players} needed".format({"players":min_players})
	else:
		for pilot_selector in _get_pilot_selectors():
			if not pilot_selector in mapping_controls_pilot.values():
				mapping_controls_pilot[controls] = pilot_selector
				(pilot_selector as PilotSelector).set_controls(controls)
				_display_species(_get_first_undisplayed_species(), pilot_selector)
				(pilot_selector as PilotSelector).set_status('joined')
				break
	_update_touch_ui()

func _update_touch_ui() -> void:
	if not has_node("TouchUI"):
		return
	var touch_ui = $TouchUI
	if TOUCH_CONTROLS not in mapping_controls_pilot:
		touch_ui.set_mode("join")
		return
	var pilot: PilotSelector = mapping_controls_pilot[TOUCH_CONTROLS]
	if pilot.is_status("selected") or pilot.is_status("ready"):
		touch_ui.set_mode("selected")
	else:
		touch_ui.set_mode("browse")
				
func _on_pilot_selector_next(pilot_selector: PilotSelector) -> void:
	_unclaim_displayed_species(pilot_selector)
	_display_adjacent_species(1, pilot_selector)
	
func _on_pilot_selector_previous(pilot_selector: PilotSelector) -> void:
	_unclaim_displayed_species(pilot_selector)
	_display_adjacent_species(-1, pilot_selector)
	
func _display_species(species: Species, pilot_selector: PilotSelector):
	mapping_pilot_displayed_species[pilot_selector] = species
	pilot_selector.set_species(species)
	
func _display_adjacent_species(operator: int, pilot_selector: PilotSelector):
	var current_species = mapping_pilot_displayed_species[pilot_selector]
	var current_index = available_species.find(current_species)
	current_index = Utils.mod(current_index + operator, len(available_species))
	var selected_species_indices = []
	for species in mapping_pilot_claimed.values():
		if species in available_species:
			selected_species_indices.append(available_species.find(species))
	while current_index in selected_species_indices:
		current_index = Utils.mod(current_index + operator,len(available_species))
	_display_species(available_species[current_index], pilot_selector)
	
func _claim_displayed_species(pilot_selector: PilotSelector):
	var species = mapping_pilot_displayed_species[pilot_selector]
	mapping_pilot_claimed[pilot_selector] = species
	
	for any_pilot_selector in mapping_pilot_displayed_species:
		if any_pilot_selector != pilot_selector and mapping_pilot_displayed_species[any_pilot_selector] == species:
			_display_adjacent_species(+1, any_pilot_selector)
	
func _unclaim_displayed_species(pilot_selector: PilotSelector):
	if not pilot_selector in mapping_pilot_claimed:
		return
	mapping_pilot_claimed.erase(pilot_selector)
	pilot_selector.set_status('joined')
	_update_touch_ui()
	
func _get_first_undisplayed_species():
	for species in available_species:
		if not species in mapping_pilot_displayed_species.values():
			return species

func disable():
	set_process(false)
	set_process_input(false)
	_touch_fire_down.clear()
	if has_node("TouchUI"):
		$TouchUI.set_mode("hidden")
	
func enable():
	set_process(true)
	set_process_input(true)
	_touch_fire_down.clear()
	_update_touch_ui()
	
func reset_ready_pilots():
	for pilot in _get_pilot_selectors():
		if pilot.is_status('ready'):
			pilot.set_status('selected')
	_update_touch_ui()

func _get_pilot_selectors() -> Array:
	var pilots := []
	for child in get_children():
		if child is PilotSelector:
			pilots.append(child)
	return pilots

func get_players_data() -> Array[Player]:
	var players : Array[Player] = []
	for child in get_children():
		if child is PilotSelector and child.is_status('ready'):
			players.append(child.get_player_data())
	return players

func _on_pilot_ready_selected(pilot_selector: PilotSelector):
	pilot_selector.set_status('ready')
	_check_all_ready()
	_update_touch_ui()
	
func _on_pilot_back_selected(pilot_selector: PilotSelector):
	_unclaim_displayed_species(pilot_selector)
	
func _on_pilot_disconnect_selected(pilot_selector: PilotSelector):
	_disconnect_pilot(pilot_selector)

func _check_all_ready():
	for pilot in _get_pilot_selectors():
		if pilot.is_status('joined') or pilot.is_status('selected'):
			return
	
	if len(mapping_pilot_claimed) >= min_players:
		emit_signal("selection_completed")
		set_process_input(false)
		
func _disconnect_pilot(pilot_selector: PilotSelector):
	_unclaim_displayed_species(pilot_selector)
	mapping_pilot_displayed_species.erase(pilot_selector) 
	mapping_controls_pilot.erase(pilot_selector.get_controls())
	pilot_selector.set_status('disabled')
	reset_ready_pilots()
