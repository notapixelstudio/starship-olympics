extends Control

const MAX_PLAYERS = 4
const MIN_PLAYERS = 1
const NUM_KEYBOARDS = 2

enum ALL_SPECIES {SPECIES0, SPECIES1, SPECIES2, SPECIES3, SPECIES4}
onready var container = $Container
onready var fight_node = $BottomHUD/Fight
onready var ready_to_fight = $CanvasLayer/ReadyToFight
onready var top_hud = $TopHUD
onready var smoke_screen = $SmokeScreen
var ordered_species : Array # as available_species Dic [str:Resource]

signal fight
signal start_demo

var selected_index = []
var players_controls : Array
var num_players : int = 0

func _ready():
	# Soundtrack.play("Lobby", true)
	fight_node.visible = false
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	post_ready()

	global.remotesServer.connect("new_remote_connected", self, "_onNewRemote")
	global.remotesServer.connect("remote_disconnected", self, "_onRemoteDisconnected")
	
func _onNewRemote(id):
	print("new Remote")
	var remoteControl = "rm"+str(id)
	add_controls(remoteControl)
 
func _onRemoteDisconnected(id):
	var joy = "rm"+str(id)
	change_controls(joy, "no")
	pass
	
func post_ready():
	ordered_species = global.get_ordered_species()
	
	var i = 0
	for child in container.get_children():
		assert(child is PlayerSelection)
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
	var actual_players = min(NUM_KEYBOARDS, MAX_PLAYERS - len(joypads))
	var controls = assign_controls(actual_players)
	for control in controls:
		assert(add_controls(control))
		
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
			# print_debug("Found it ", index_to_change, " and control is ", child.controls)
			break
		index_to_change += 1
	last = new_key
	if container.get_child(count-1).controls.findn( "joy") >=0:
		last="kb1"
	for i in range (index_to_change, count):
		var child = container.get_child(count-i-1)
		var to_change = last
		last = child.controls
		assert(child is PlayerSelection)
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
	# check on remotes
	var numRemotes = global.remotesServer.get_connected_remotes()
	for i in range(numRemotes):
		players_controls.append("rm"+str(i+1))
		if len(players_controls) >= MAX_PLAYERS:
			break
			
	# now put NO on the rest of players
	return players_controls

# utils
func get_players() -> Array: # Array[InfoPlayer]
	var players = []
	for child in container.get_children():
		if child.controls != "no" and child.selected:
			players.append(child.get_info_player())
	return players

func get_adjacent(operator:int, player_selection : Node):
	restart_timer()
	var current_index = ordered_species.find(player_selection.species)
	current_index = global.mod(current_index + operator,len(ordered_species))
	while current_index in selected_index:
		current_index = global.mod(current_index + operator,len(ordered_species))
	player_selection.change_species(ordered_species[current_index])

func _on_joy_connection_changed(device_id, connected):
	var joy = "joy"+str(device_id+1)
	if connected:
		add_controls(joy)
	else:
		change_controls(joy, "no")

func ready_to_fight():
	var players = get_players()
	if len(players) >= MIN_PLAYERS:
		ready_to_fight.start(players, global.win)
		smoke_screen.visible = true
	else:
		print_debug("not enough players")

func selected(player: PlayerSelection):
	ready_to_fight.deactivate()
	restart_timer()
	var species = player.species
	
	var current_index = ordered_species.find(species)
	selected_index.append(current_index)
	for child in container.get_children():
		if not child.selected and child.species == species:
			get_adjacent(+1, child)
	var players = get_players()
	if len(players) >= MIN_PLAYERS:
		deselected = false
		fight_node.set_label(fight_mode.to_upper())
		#global.shake_node(fight_node, $Tween)
		fight_node.wiggle()
		fight_node.visible = true
	
	$Timer.stop()
	$Label.text = ""

# this is in order to avoid to leave the screen if there is just one player
# TODO: it should be with signals
var deselected = false

func deselected(species: Species):
	if not len(get_players()):
		restart_timer()
	var current_index = ordered_species.find(species)
	if selected_index.find(current_index) >= 0:
		selected_index.remove(selected_index.find(current_index))
	var players = get_players()
	if len(players) < MIN_PLAYERS:
		deselected = true
		global.shake_node(fight_node, $Tween)
		fight_node.idle()
		fight_node.visible = false


func _unhandled_input(event):
	if event.is_action_pressed("pause") and not global.demo:
		Events.emit_signal("nav_to_menu")
		
var fight_mode = "vs Mode"

func _process(delta):

	var teams = 0
	var at_least_one_character_in_team_selected = false
	var at_least_one_solo_selected = false
	var dict_species = {}
	for child in container.get_children():
		if child.disabled:
			continue
		var species_name = child.species.name
		if not species_name in dict_species:
			dict_species[species_name] = { child.species.id: child}
		else:
			dict_species[species_name][child.species.id] = child
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
			# fight_mode = "co-op"
			pass
	fight_node.set_label('play %s' % fight_mode)
	if $Timer.time_left < 5 and not $Timer.is_stopped():
		$Label.text = "DEMO MODE IN {time_left}".format({"time_left":int($Timer.time_left)})
	else:
		$Label.text = ""
		
func deselect():
	for child in container.get_children():
		if child.disabled:
			continue
		child.deselect()

func restart_timer():
	$Timer.start()
	global.demo = false
	
func _on_Timer_timeout():
	global.demo = true
	emit_signal("fight", self.get_players(), fight_mode)
	

func _on_ReadyToFight_letsfight():
	var players = get_players()
	emit_signal("fight", players, fight_mode)

func reset():
	ready_to_fight.deactivate()

func _on_ReadyToFight_deactivated():
	smoke_screen.visible = false
