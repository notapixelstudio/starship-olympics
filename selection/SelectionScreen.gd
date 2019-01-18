extends Control

const MAX_PLAYERS = 4
const MIN_PLAYERS = 2

onready var container = $Container

var available_species : Dictionary
var ordered_species : Array

signal fight
signal someone_selected

var selected_index = []
var players_controls : Array
var num_players : int = 0

func _ready():
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

func initialize(available_species:Dictionary):
	ordered_species = available_species.keys()
	
	var i = 0
	for child in container.get_children():
		assert(child is Species)
		#set all to no
		child.set_controls_by_string("no")
		child.change_species(ordered_species[i])
		child.connect("prev", self, "get_adjacent", [-1, child])
		child.connect("next", self, "get_adjacent", [+1, child])
		child.connect("selected", self, "selected")
		child.connect("deselected", self, "deselected")
		child.connect("ready_to_fight", self, "ready_to_fight")
		i +=1
	var controls = assign_controls(2)
	for control in controls:
		print(add_controls(control))

# debug
var pressed = false
var debug_joy = 0
func _unhandled_input(event):
	if event.is_action_pressed("debug"):
		Input.emit_signal("joy_connection_changed", debug_joy+1, true)
		debug_joy = global.mod((debug_joy + 1), MAX_PLAYERS-1)
	elif event.is_action_pressed("debug_cancel"):
		debug_joy = global.mod((debug_joy - 1), MAX_PLAYERS-1)
		Input.emit_signal("joy_connection_changed", debug_joy+1, false)

# end debug

func add_controls(key : String) -> bool:
	"""
	Add a controller (keyboard or joypad) and move other to the right
	return false if reach limit of MAX_PLAYERS.
	If no, shift backwards
	"""
	var shift:bool = false
	var last: String = ""
	var first = container.get_child(0)
	if first.controls != "no":
		shift = true
		last = first.controls
	first.set_controls_by_string(key)
	print("set ", first.name, " to ", key)
	var i = 0
	for child in container.get_children():
		if child.controls == key:
			i+=1
			continue
			
		if shift:
			var tmp = child.controls
			print(child.name , " with ", last, ". It was ", tmp)
			child.set_controls_by_string(last)
			last = tmp
		print( "child ", i, " with controls ", child.controls)
		i+=1
	return true

func change_controls(key:String, new_key:String) -> bool:
	var shift_backwards : bool = false
	var last : String = ""
	#iterate backwards
	print("CHANGE TO ", new_key, ":")
	var count = container.get_child_count()
	var index_to_change : int =0
	for child in container.get_children():
		if child.controls == key:
			print("Found it ", index_to_change, " and control is ", child.controls)
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
		print("index is ", count-i, " and control is ", last)
		child.set_controls_by_string(to_change)
		
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
	print("players who are going to fight are.. " , players)
	for player in players:
		print(player.name)
	if len(players) >= MIN_PLAYERS:
		emit_signal("fight", players)
	else:
		print("not enough players")

func selected(species:String):
	var current_index = ordered_species.find(species) 
	selected_index.append(current_index)
	print(selected_index)
	for child in container.get_children():
		if not child.selected and child.species == species:
			get_adjacent(+1, child)
	emit_signal("someone_selected", species)

func deselected(species:String):
	var current_index = ordered_species.find(species) 
	selected_index.remove(selected_index.find(current_index))
	print(selected_index)
	print("delestected this: ", species)