extends Control

signal selection_completed

@export var min_players := 2
@export var ready_to_fight: PackedScene

var relevant_actions := {}
var mapping_controls_pilot := {}
var mapping_pilot_displayed_species := {}
var mapping_pilot_claimed := {}
var available_species : Array[Species] = []

func _ready():
	%Label.visible = false
	available_species = Species.get_all_unlocked()
	for action in InputMap.get_actions():
		for action_name in ["_fire", "_left", "_right", "_up", "_down"]:
			if action_name in action and not "ui" in action: 
				relevant_actions[action] = (InputMap.action_get_events(action))
				
	# hook up all pilot selector events
	for child in get_children():
		if child is not PilotSelector:
			continue
		child.next.connect(_on_pilot_selector_next)
		child.previous.connect(_on_pilot_selector_previous)
		
## return the first relevant action matching the given InputEvent, or null if it was not found
func _get_action_from_event(event: InputEvent):
	for action in relevant_actions:
		if InputMap.event_is_action(event, action):
			return action
	return null
	
func _input(event: InputEvent):
	if not event.is_pressed():
		return
		
	var action = _get_action_from_event(event)
	if action == null:
		return
	
	var controls = (action as String).split("_")[0] # kb1, joy1, etc.
	var action_suffix = (action as String).split("_")[1] # fire, left, etc.
	
	if controls in mapping_controls_pilot:
		var pilot_selector : PilotSelector = mapping_controls_pilot[controls]
		match action_suffix:
			'fire':
				if pilot_selector in mapping_pilot_claimed:
					if len(mapping_pilot_claimed) >= min_players:
						print("we can go to next scene")
						%Label.visible = false
						emit_signal("selection_completed")
						set_process_input(false)
						return
				else:
					_claim_displayed_species(pilot_selector)
					pilot_selector.set_status('selected')
					%Label.visible = true
					if len(mapping_pilot_claimed) >= min_players:
						%Label.text = "{players} READY".format({"players":len(mapping_pilot_claimed)})
					else: 
						%Label.text = "Not enough players. {players} needed".format({"players":min_players})
				
			#'left':
				#if %Label.visible:
					#%Label.visible = false
				#_unclaim_displayed_species(pilot_selector)
				#_display_adjacent_species(-1, pilot_selector)
			#'right':
				#if %Label.visible:
					#%Label.visible = false
				#_unclaim_displayed_species(pilot_selector)
				#_display_adjacent_species(+1, pilot_selector)
	else:
		# join
		for pilot_selector in _get_pilot_selectors():
			if not pilot_selector in mapping_controls_pilot.values():
				mapping_controls_pilot[controls] = pilot_selector
				(pilot_selector as PilotSelector).set_controls(controls)
				
				_display_species(_get_first_undisplayed_species(), pilot_selector)
				
				(pilot_selector as PilotSelector).set_status('joined')
				# FIXME - NOT RELEVANT ANYMORE?
				# if in demo playtest, also select the pre-assigned character
				#if global.demo_playtest:
					#var mapping = {
						#'joy1': 'trixens_1',
						#'joy2': 'umidorians_1',
						#'joy3': 'robolords_1',
						#'joy4': 'mantiacs_1',
						#'kb1': 'pentagonions_1',
						#'kb2': 'auriels_1'
					#}
					#(pilot_selector as PilotSelector).set_species(global.get_species(mapping[controls]))
				if %Label.visible:
					%Label.visible = false	
				return
				
## called whenever a pilot selector asks for the next character
func _on_pilot_selector_next(pilot_selector: PilotSelector) -> void:
	if %Label.visible:
		%Label.visible = false
	_unclaim_displayed_species(pilot_selector)
	_display_adjacent_species(1, pilot_selector)
	
## called whenever a pilot selector asks for the previous character
func _on_pilot_selector_previous(pilot_selector: PilotSelector) -> void:
	if %Label.visible:
		%Label.visible = false
	_unclaim_displayed_species(pilot_selector)
	_display_adjacent_species(-1, pilot_selector)
	
## display the given Species in the given PilotSelector
func _display_species(species: Species, pilot_selector: PilotSelector):
	mapping_pilot_displayed_species[pilot_selector] = species
	pilot_selector.set_species(species)
	
## change the displayed Species in the given PilotSelector with the next one (if operator == +1)
## or the previous one (if operator == -1)
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
	
## claim the currently displayed species in the given PilotSelector for the corresponding player
func _claim_displayed_species(pilot_selector: PilotSelector):
	var species = mapping_pilot_displayed_species[pilot_selector]
	var index = available_species.find(species)
	mapping_pilot_claimed[pilot_selector] = species
	
	# if a species is claimed, no pilot selectors can display it anymore
	# so each displayed species should be checked then changed if needed
	for any_pilot_selector in mapping_pilot_displayed_species:
		if any_pilot_selector != pilot_selector and mapping_pilot_displayed_species[any_pilot_selector] == species:
			_display_adjacent_species(+1, any_pilot_selector)
	
## remove the claim for the species currently displayed on the given PilotSelector (if actually
## claimed) - this also causes the selector to lose its selected status and revert back to joined
func _unclaim_displayed_species(pilot_selector: PilotSelector):
	if not pilot_selector in mapping_pilot_claimed:
		return
	var species = mapping_pilot_claimed[pilot_selector]
	mapping_pilot_claimed.erase(pilot_selector)
	pilot_selector.set_status('joined')
	
## return the first Species that is currently not displayed by any PilotSelector
func _get_first_undisplayed_species():
	for species in available_species:
		if not species in mapping_pilot_displayed_species.values():
			return species

## disables all inputs to this panel
func disable():
	set_process(false)
	set_process_input(false)
	
## enables inputs to this panel
func enable():
	set_process(true)
	set_process_input(true)

func _get_pilot_selectors() -> Array:
	var pilots := []
	for child in get_children():
		if child is PilotSelector:
			pilots.append(child)
	return pilots

func get_players_data() -> Array[Player]:
	var players : Array[Player] = []
	for child in get_children():
		if child is PilotSelector and child.is_status('selected'):
			players.append(child.get_player_data())
	return players
