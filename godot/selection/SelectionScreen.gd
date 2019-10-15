extends Control

const MAX_PLAYERS = 4
const MIN_PLAYERS = 1
const NUM_KEYBOARDS = 2

enum ALL_SPECIES {SPECIES0, SPECIES1, SPECIES2, SPECIES3, SPECIES4}
onready var container = $Container
onready var fight_node = $BottomHUD/Fight
var available_species : Dictionary
var ordered_species : Array # as available_species Dic [str:Resource]

signal fight
signal back

var selected_index = []
var players_controls : Array
var num_players : int = 0

func _ready():
	# Soundtrack.play("Lobby", true)
	fight_node.visible = false
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")


func initialize(_available_species:Dictionary):
	available_species = _available_species
	ordered_species = available_species.values()

	var i = 0
	for child in container.get_children():
		assert(child is Species)
		#set all to no
		child.set_controls(global.CONTROLSMAP[global.Controls.NO])
		child.change_species(ordered_species[i])
		child.connect("prev", self, "get_adjacent", [-1, child])
		child.connect("next", self, "get_adjacent", [+1, child])
		child.connect("selected", self, "selected")
		child.connect("deselected", self, "deselected")
		child.connect("ready_to_fight", self, "ready_to_fight")
		i +=1
		# it gives the name of the player
		child.uid = i
	var joypads = Input.get_connected_joypads()
	print(len(joypads))
	var actual_players = min(NUM_KEYBOARDS, MAX_PLAYERS - len(joypads))
	var controls = assign_controls(actual_players)
	for control in controls:
		print(add_controls(control))

func add_controls(new_controls : String) -> bool:
	"""
	Add a controller (keyboard or joypad) and move other to the right
	return false if reach limit of MAX_PLAYERS.
	If no, shift backwards
	"""
	# TODO: check this
	var shift:bool = false
	var last: String = ""
	var first = container.get_child(0)
	if first.controls != global.CONTROLSMAP[global.Controls.NO]:
		shift = true
		last = first.controls
	first.set_controls(new_controls)
	var i = 0
	for child in container.get_children():
		if child.controls == new_controls:
			i+=1
			continue

		if shift:
			var tmp = child.controls
			child.set_controls(last)
			last = tmp
		i+=1
	return true

func change_controls(key:String, new_key:String) -> bool:
	var shift_backwards : bool = false
	var last : String = ""
	#iterate backwards
	var count = container.get_child_count()
	var index_to_change : int =0
	for child in container.get_children():
		if child.controls == key:
			# print("Found it ", index_to_change, " and control is ", child.controls)
			break
		index_to_change += 1
	last = new_key
	if container.get_child(count-1).controls.findn( "joy") >=0:
		last="kb1"
	for i in range (index_to_change, count):
		var child = container.get_child(count-i-1)
		var to_change = last
		last = child.controls
		assert(child is Species)
		child.set_controls(to_change)

	return false

func assign_controls(num_keyboards : int) -> Array:
	"""
	Depending on how many keyboard want to play
	it puts keyboard control first then eventually disable the rest
	"""
	players_controls = []
	var num_players = 0

	# set for keyboards
	for i in range(num_keyboards):
		num_players +=1
		players_controls.append("kb"+str(num_keyboards-i))

	# check on joypad
	var joypads = Input.get_connected_joypads()
	for i in range(len(joypads)):
		num_players+=1
		players_controls.append("joy"+str(i+1))
		if len(players_controls) >= MAX_PLAYERS:
			break

	# now put NO on the rest of players
	return players_controls

# utils
func get_players() -> Array:
	var players = []
	for child in container.get_children():
		if child.controls != "no" and child.selected:
			players.append(child)
	return players

func get_adjacent(operator:int, player_selection : Node):
	var current_index = ordered_species.find(player_selection.species_template)
	current_index = global.mod(current_index + operator,len(ordered_species))
	while current_index in selected_index:
		current_index = global.mod(current_index + operator,len(ordered_species))
	player_selection.change_species(ordered_species[current_index])

func _on_joy_connection_changed(device_id, connected):
	var joy = "joy"+str(device_id+1)
	if connected:
		print("Recognise controller: ", Input.get_joy_name(device_id))
		add_controls(joy)
	else:
		change_controls(joy, "no")

func ready_to_fight():
	var players = get_players()
	print("players who are going to fight are... " , players)
	if len(players) >= MIN_PLAYERS:
		emit_signal("fight", players, fight_mode)
	else:
		print("not enough players")

func selected(species:SpeciesTemplate):
	var current_index = ordered_species.find(species)
	selected_index.append(current_index)
	for child in container.get_children():
		if not child.selected and child.species_template == species:
			get_adjacent(+1, child)
	var players = get_players()
	if len(players) >= MIN_PLAYERS:
		deselected = false
		fight_node.set_label(fight_mode.to_upper())
		#global.shake_node(fight_node, $Tween)
		fight_node.wiggle()
		fight_node.visible = true

# this is in order to avoid to leave the screen if there is just one player
# TODO: it should be with signals
var deselected = false

func deselected(species:SpeciesTemplate):
	var current_index = ordered_species.find(species)
	selected_index.remove(selected_index.find(current_index))
	var players = get_players()
	if len(players) < MIN_PLAYERS:
		deselected = true
		global.shake_node(fight_node, $Tween)
		fight_node.idle()
		fight_node.visible = false


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if len(get_players())<=0:
			if not deselected:
				emit_signal("back")
			else:
				deselected = false

var fight_mode = "vs Mode"

func _process(delta):
	var teams = 0
	var at_least_one_character_in_team_selected = false
	var at_least_one_solo_selected = false
	var dict_species = {}
	for child in container.get_children():
		if child.disabled:
			continue
		var species_name = child.species_template.species_name
		if not species_name in dict_species:
			dict_species[species_name] = {child.species_template.id: child}
		else:
			dict_species[species_name][child.species_template.id] = child
		child.unset_team()

	for s in dict_species:
		if len(dict_species[s])>1:
			teams += 1

		for key in dict_species[s]:
			var p = dict_species[s][key]
			if len(dict_species[s])>1:
				p.set_team(s)
				if p.selected:
					at_least_one_character_in_team_selected = true
			else:
				if p.selected:
					at_least_one_solo_selected = true

	fight_mode = "versus"
	if len(get_players()) == 1:
		fight_mode = "solo"
	elif len(get_players()) == 2:
		if at_least_one_character_in_team_selected and not at_least_one_solo_selected:
			fight_mode = "co-op"
	fight_node.set_label('play %s' % fight_mode)