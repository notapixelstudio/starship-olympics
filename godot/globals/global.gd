extends Node

# single truth point
var local_multiplayer

const SETTINGS_FILENAME = "res://export.cfg"
const E = 2.71828

const isometric_offset = Vector2(0,32)

var enable_camera := true 

var enable_analytics : bool = false setget _set_analytics
signal send_statistics

func _set_analytics(new_value):
	enable_analytics = new_value
	GameAnalytics.build_version = version
	GameAnalytics.enabled = enable_analytics
	connect("send_statistics", GameAnalytics, "add_event")

var array_device = ["kb1", "kb2", "joy1", "joy2", "joy3", "joy4"]
onready var device 

var array_time_scale = ["0.5", "0.6", "0.7", "0.8", "0.9", "1.0"] 
var time_scale = "1.0" setget _set_time_scale

func _set_time_scale(new_value):
	time_scale = new_value
	# decomment if we want to update Engine.time_scale globally
	# Engine.time_scale = float(time_scale)


var available_languages = {
	"english": "en",
	"español": "es",
	"italiano": "it",
	"euskara": "eu",
	"français": "fr",
	"deutsch": "de"
	}
onready var language: String setget _set_language, _get_language
var array_language: Array = ["english", "italiano", "español", "euskara", "français", "deutsch"]
var full_screen = true setget _set_full_screen

func _set_full_screen(value: bool):
	full_screen = value
	OS.window_fullscreen = full_screen
	OS.move_window_to_foreground()
	if full_screen:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

var unlock_mode = "custom" setget _set_unlock_mode
var array_unlock_mode = ["custom", "demo", "core", "unlocked"]

func _set_unlock_mode(value: String):
	# This is atypical, but we want to keep the unlocker mode to custom when we come back at it
	# unlock_mode = value
	var file_unlocker := {
		"demo": "res://assets/config/demo_unlocker.json",
		"core": "res://assets/config/only_core.json",
		"unlocked": "res://assets/config/unlocked.json"
	}
	var file_path := ""
	if value in file_unlocker:
		file_path = file_unlocker[value]
	else:
		file_path = "res://assets/config/custom_unlocker.json"
	var data = read_file(file_path)
	if data:
		TheUnlocker.load_state(data)
	persistance.save_game()

func _set_language(value:String):
	language = value
	TranslationServer.set_locale(available_languages[language])

func _get_language():
	return language

var version = "0.7.0-internal" setget set_version
var first_time = true

func set_version(value):
	print("Version is and will be {v}".format({"v": version}))


# OPTIONS need a min and a MAX
const min_win = 1
var win = 3
const max_win = 5

var campaign_win = win

var custom_win:int = win setget set_custom_win

func set_custom_win(value):
	custom_win = value
	win = custom_win

var flood = "off" 

var laser = "off" 

# levels
var level
var array_level

var audio_on : bool setget _audio_on

var demo : bool = false

func _audio_on(new_value):
	audio_on = new_value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), audio_on)

var master_volume : int = 50 setget _set_master_volume
var min_master_volume : int = 0
var max_master_volume: int = 100

var rumbling: bool = true

func _set_master_volume(new_value): 
	master_volume = new_value
	var db_volume = linear2db(float(new_value)/100)
	var bus_name = "Master"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)

var music_volume : int = 50 setget _set_music_volume
var min_music_volume : int = 0
var max_music_volume: int = 100

func _set_music_volume(new_value): 
	music_volume = new_value
	var db_volume = linear2db(float(new_value)/100)
	var bus_name = "Music"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
	
var sfx_volume : int = 50 setget _set_sfx_volume
var min_sfx_volume : int = 0
var max_sfx_volume: int = 100

func _set_sfx_volume(new_value): 
	sfx_volume = new_value
	var db_volume = linear2db(float(sfx_volume)/100)
	var bus_name = "SFX"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)


# DEBUG
var debug : bool = false

# Soundtrack
onready var bgm = Soundtrack
# Controls
enum Controls {KB1, KB2, JOY1, JOY2, JOY3, JOY4, NO, CPU}

const CONTROLSMAP = {
	Controls.NO : "no",
	Controls.CPU : "cpu",
	Controls.KB1 : "kb1",
	Controls.KB2 : "kb2",
	Controls.JOY1 : "joy1",
	Controls.JOY2 : "joy2",
	Controls.JOY3 : "joy3",
	Controls.JOY4 : "joy4"
}

const CONTROLSMAP_TO_KEY = {
	"no" : Controls.NO,
	"cpu" : Controls.CPU,
	"kb1" : Controls.KB1,
	"kb2" : Controls.KB2,
	"joy1" : Controls.JOY1,
	"joy2" : Controls.JOY2,
	"joy3" : Controls.JOY3,
	"joy4" : Controls.JOY4
}

const MAX_PLAYERS = 4

var colors = {
	WHITE = Color(1.0, 1.0, 1.0),
	YELLOW = Color(1.0, .757, .027),
	GREEN = Color(.282, .757, .255),
	BLUE = Color(.098, .463, .824),
	PINK = Color(.914, .118, .388)
}

var scores
var campaign_mode : bool = false setget set_campaign_mode

func set_campaign_mode(value):
	campaign_mode = value
	if campaign_mode:
		win = campaign_win
	else:
		win = custom_win
	
# 'from_scene' will have the reference to the previous scene (main scene at the beginning)
var from_scene = "res://special_scenes/title_screen/MainScreen.tscn"

func _input(event):
	if event.is_action_pressed("fullscreen"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		OS.window_fullscreen = not OS.window_fullscreen
	
	if demo and event.is_action_pressed("force_reset"):
		get_tree().change_scene("res://local_multiplayer/LocalMultiplayer.tscn")
		get_tree().paused = false
		
func _ready():
	# we want to handle quit by ourselves
	get_tree().set_auto_accept_quit(false)
	
	print("Starting game...")
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_to_group("persist")
	
	# setup language and add if not exists
	var generic_locale = TranslationServer.get_locale().split("_")[0]
	# language = TranslationServer.get_locale_name(generic_locale).to_lower()
	for lang in available_languages:
		if generic_locale == available_languages[lang]:
			language = lang
	
	var saved_data = persistance.get_saved_data()
	var k = get_path()
	var global_key = String(get_path())
	
	if not saved_data or not "version" in saved_data[global_key] or check_version(saved_data[global_key]["version"], version):
		print("We need to update the saved game")
		first_time = true
		persistance.save_game()
	else:
		first_time = false
	if persistance.load_game():
		print("Successfully load the game")
	else:
		print("Something went wrong while loading the game data")

func read_file(path: String) -> Dictionary:
	# When we load a file, we must check that it exists before we try to open it or it'll crash the game
	var file = File.new()
	if not file.file_exists(path):
		print("The save file does not exist.")
		return {}
	file.open(path, File.READ)
	print("We are going to load from this JSON: ", file.get_path_absolute())
	# parse file data - convert the JSON back to a dictionary
	var data = {}
	data = parse_json(file.get_as_text())
	file.close()
	return data

var execution_uuid : String
func start_execution():
	execution_uuid = UUID.v4()
	Events.emit_signal('execution_started')
	
func end_execution():
	# trigger quit
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	
func _notification(what):
	# actual quitting
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("Thanks for playing")
		GameAnalytics.end_session()
		if enable_analytics:
			yield(GameAnalytics, "message_sent")
		Events.emit_signal('execution_ended')
		get_tree().quit() # default behavior
	
# INPUT MAPPING
const INPUT_ACTIONS = ["kb1", "kb2", "joy1", "joy2", "joy3", "joy4"]
var input_mapping : Dictionary setget _set_input_mapping, _get_input_mapping

var joy_input_map = {
	"analog_0_1"  : "Left_Stick_Right",
	"analog_0_-1" : "Left_Stick_Left",
	"analog_1_1"  : "Left_Stick_Down",
	"analog_1_-1" : "Left_Stick_Up",
	"analog_2_1"  : "Right_Stick_Right",
	"analog_2_-1" : "Right_Stick_Left",
	"analog_3_1"  : "Right_Stick_Down",
	"analog_3_-1" : "Right_Stick_Up",
	"0": "Cross",
	"1": "Circle",
	"2": "Square",
	"3": "Triangle",
	"4": "L1",
	"5": "R1",
	"6": "L2",
	"7": "R2",
	"8": "Left_Stick_Click",
	"9": "Right_Stick_Click",
	"10": "Select",
	"11": "Start",
	"12": "Dpad_Up",
	"13": "Dpad_Down",
	"14": "Dpad_Left",
	"15": "Dpad_Right"
}

var keyboard_input_map = {
	"Up": "Arrow_Up",
	"Down": "Arrow_Down",
	"Left": "Arrow_Left",
	"Right": "Arrow_Right",
	"BackSpace": "Backspace_Alt",
	"*": "Asterisk",
	
}


func event_to_text(event: InputEvent):
	"""
	event: @type InputEvent
	return the event in a human readable form. For reference `joy_input_map`
	"""
	if event is InputEventKey:
		var key = event.as_text()
		if key in keyboard_input_map:
			key = keyboard_input_map[key]
		return {"key": key, "device_id": event.device, "device": "kb"}
	elif event is InputEventJoypadButton:
		return {"key": joy_input_map[str(event.button_index)], "device_id": event.device, "device": "joy"}
	elif event is InputEventJoypadMotion:
		if event.axis_value > 0:
			event.axis_value = 1
		else:
			event.axis_value = -1
		var command = joy_input_map["analog_"+str((event as InputEventJoypadMotion).axis) + "_" + str((event as InputEventJoypadMotion).axis_value)]
		return {"key": command, "device_id": event.device, "device": "joy"}

func event_from_text(device: String, command: String, device_id = 0) -> InputEvent:
	"""
	device: e.g. kb1, kb2, joy1, joy2
	command: e.g. 0, 1, 2 , analog_1_-1, M, N 
	"""
	var e : InputEvent
	if "kb" in device:
		var inverted_input_map = global.invert_map(keyboard_input_map)
		var command_text = command
		if command_text in inverted_input_map:
			command_text = inverted_input_map[command_text]
		command_text = OS.find_scancode_from_string(command_text)
		e = InputEventKey.new()
		e.scancode = command_text
	elif "joy" in device:
		var inverted_input_map = global.invert_map(joy_input_map)
		var command_text = inverted_input_map[command]
		if "analog" in command_text:
			e = InputEventJoypadMotion.new()
			e.axis = int(command_text.split("_")[1])
			e.axis_value = int(command_text.split("_")[2])
		else:
			e = InputEventJoypadButton.new()
			e.button_index = int(command_text)
		e.device = device_id
	return e

func _set_input_mapping(value_):
	"""
	will add the entire input dictionary to the game
	"""
	input_mapping=value_
	for device in INPUT_ACTIONS:
		for action in input_mapping:
			if device in action:
				var commands = input_mapping[action]
				var events = []
				for command in commands:
					var event = event_from_text(device, command["key"], command["device_id"])
					events.append(event)
				remap_multiple_actions_to(action, events)
	
func _get_input_mapping():
	var ret = {}
	for device in INPUT_ACTIONS:
		for action in InputMap.get_actions():
			if device in action:
				ret[action] = []
				for event in InputMap.get_action_list(action):
					ret[action].append(event_to_text(event))
	return ret

var default_input_joy := {
	"fire": ["Cross", "Square", "Circle", "Triangle", "L1", "R1", "L2", "R2"], 
	"right": ["Dpad_Right", "Left_Stick_Right"],
	"left": ["Dpad_Left", "Left_Stick_Left"], 
	"down": ["Dpad_Down", "Left_Stick_Down"],
	"up":["Dpad_Up", "Left_Stick_Up"]
}

var default_input :=  {
	"kb1": {
		"fire":["M"], "down":["Down"], "left":["Left"], "right":["Right"], "up":["Up"]
	},
	"kb2": { 
		"down":["S"], "fire":["1"], "left":["A"], "right":["D"], "up":["W"]
	},
	"joy1": default_input_joy,
	"joy2": default_input_joy,
	"joy3": default_input_joy,
	"joy4": default_input_joy
}

var input_mapping_joy := {
	"joy1": default_input_joy,
	"joy2": default_input_joy,
	"joy3": default_input_joy,
	"joy4": default_input_joy
}

var array_joylayout = ["default", "setup1", "setup2", "setup3", "custom"]
onready var joylayout: String = array_joylayout[0] setget _set_joylayout, _get_joylayout

func _set_joylayout(value):
	joylayout = value

func _get_joylayout():
	return joylayout
	
func set_default_mapping(device:String) -> Dictionary:
	var ret_mapping = {}
	var this_mapping = default_input[device]
	var device_id: int = int(device.right(len(device)-1))-1
	for action in this_mapping:
		
		var complete_action = device + "_" + action
		var events = []
		for command in this_mapping[action]:
			var event = event_from_text(device, command, device_id)
			events.append(event)
		remap_multiple_actions_to(complete_action, events)
		ret_mapping[complete_action] = this_mapping[action]
	persistance.save_game()
	return ret_mapping
	
func check_input_event(action_: String, event:InputEvent):
	return event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion

func clear_mapping(action:String, event: InputEvent):
	InputMap.action_erase_event(action, event)
	var alert_scene = load("res://interface/OverlayMessage.tscn").instance()
	alert_scene.message = "ACTION BINDING FOR [color=red]{action}[/color] OVERRIDDEN".format({"action": action.to_upper()})
	add_child(alert_scene)
	alert_scene.raise()
	
func clear_all_mapping(action: String):
	InputMap.action_erase_events(action)
	
func remap_multiple_actions_to(action: String, new_events: Array, ui_flag=true) -> String:
	"""
	new_events: Array[InputEvent]
	Will delete the events from the actions in order to put the new ones
	"""
	var current_key = ""
	
	if ui_flag:
		var acts = action.split("_")
		var id = acts[len(acts)-1]
		if id == "fire":
			id = "accept"
		var ui_action = "ui_"+id
		#TODO: remove only the existing control for that player
		for event in InputMap.get_action_list(action):
			InputMap.action_erase_event(ui_action, event)
		for new_event in new_events:
			InputMap.action_add_event("ui_"+id, new_event)
	InputMap.action_erase_events(action)
	for new_event in new_events:
		InputMap.action_add_event(action, new_event)
	return action

func remap_action_to(action: String, new_event: InputEvent) -> String:
	"""
	Given an action, and an InputEvent will set an event.
	You might pass the previous event if it's a substitution
	return event to text
	"""
	var current_key = ""
	var acts = action.split("_")
	var id = acts[len(acts)-1]
	if id == "fire":
		id = "accept"
	var ui_action = "ui_"+id
	
	InputMap.action_add_event(ui_action, new_event)
	InputMap.action_add_event(action, new_event)
	return global.event_to_text(new_event)
	

# utils
func get_state():
	"""
	get_state will return everything we need to be persistent in the game
	"""
	return {
		custom_win=custom_win,
		enable_analytics=enable_analytics,
		language=language,
		version=version,
		music_volume=music_volume,
		master_volume=master_volume,
		sfx_volume=sfx_volume,
		demo=demo,
		full_screen=full_screen,
		rumbling=rumbling,
		input_mapping=self.input_mapping,
		glow_enable=glow_enable,
		enable_camera=enable_camera,
		flood=flood,
		time_scale=time_scale,
		laser=laser
	}
	

func load_state(data:Dictionary):
	"""
	Set back everything we need to load
	"""
	for attribute in data:
		set(attribute, data[attribute])

func dir_contents(path:String, starts_with:String = "", extension:String = ".tscn"):
	"""
	@param path:String given the path 
	@return a list of filename
	"""
		
	var dir = Directory.new()
	var list_files = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(extension):
					if not starts_with or file_name.find(starts_with) == 0: 
						list_files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list_files

func mod(a,b):
	"""
	Modulus: Maybe fposmod and fmod will do the trick by its own
	"""
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret

func shake_node_backwards(node, tween):
	var actual_d_pos = node.rect_position
	tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position - Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_method(node, "set_position", node.rect_position - Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	tween.start()
	yield(tween,"tween_completed")

func shake_node(node, tween):
	var actual_d_pos = node.rect_position
	tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position + Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_method(node, "set_position", node.rect_position + Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	tween.start()
	yield(tween,"tween_completed")
	
func get_base_entity(node : Node):
	if node is Entity:
		return node
	if node == get_node("/root"):
		return null
	if not node:
		return null
	return get_base_entity(node.get_parent())
	
func check_version(saved_version: String, version_: String) -> bool:
	# Will check if the version of the saved data is smaller the current
	var saved_minor = saved_version.split(".")[1]
	var saved_patch = saved_version.split(".")[2]
	var minor = version_.split(".")[1]
	var patch = version_.split(".")[2]
	
	return int(saved_patch) < int(patch)

func send_stats(category: String, stats: Dictionary):
	emit_signal("send_statistics", category, stats)
		
func sigmoid(x, width):
	return 1-1/(1+pow(E, -10*(x/width-0.5)))
	
func join_str(array, sep=",") -> String:
	var ret = ""
	for e in array:
		ret += e+sep
	return ret.rstrip(sep)
	
	
func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2)

func invert_map(map:Dictionary):
	"""
	works on one level dictionary
	"""
	var ret = {}
	for k in map:
		ret[map[k]] = k
	return ret


var glow_enable = true setget _set_glow

func _set_glow(value):
	glow_enable = value
	

# GAMEPLAY
var the_game: TheGame = null
var the_match: TheMatch = null
var session: TheSession = null
var arena

func new_game(players) -> TheGame:
	safe_destroy_game()
	the_game = TheGame.new()
	the_game.set_players(players)
	Events.emit_signal("game_started")
	return the_game

func new_match() -> TheMatch:
	safe_destroy_match()
	the_match = TheMatch.new()
	Events.emit_signal("match_started")
	return the_match
	
func new_session() -> TheSession:
	safe_destroy_session()
	session = TheSession.new()
	
	# whenever a new session is created, InfoPlayer stats should be cleared
	the_game.reset_players()
	
	Events.emit_signal('session_started')
	return session
	
func safe_destroy_game() -> void:
	if is_game_running():
		# also delete the session
		safe_destroy_session()
		
		Events.emit_signal("game_ended")
		the_game.free()
	the_game = null
	
func safe_destroy_match() -> void:
	if is_match_running():
		global.session.add_match(the_match.to_dict())
		Events.emit_signal("match_ended")
		the_match.free()
	the_match = null
	
func safe_destroy_session() -> void:
	if is_session_running():
		# also delete the match
		safe_destroy_match()
		
		Events.emit_signal("session_ended")
		session.free()
	session = null
	
func is_game_running() -> bool:
	return the_game != null and is_instance_valid(the_game)
	
func is_match_running() -> bool:
	return the_match != null and is_instance_valid(the_match)
	
func is_session_running() -> bool:
	return session != null and is_instance_valid(session)
	
###############################
##### FILE SYSTEM UTILS #######
###############################
const SPECIES_PATH = "res://selection/characters"

func get_resources(base_path: String) -> Dictionary:
	var ret = {}
	var resources = global.dir_contents(base_path, "", ".tres")
	for filename in resources:
		var this_res = load(base_path.plus_file(filename))
		var res_id = this_res.id
		ret[res_id] = this_res
	return ret

onready var species_resources: Dictionary = get_resources(SPECIES_PATH)
func get_species(species_id: String):
	return species_resources[species_id]

func get_ordered_species() -> Array:
	var ordered_species = []
	var unlocked_species = TheUnlocker.get_unlocked_list("species")
	for species_id in unlocked_species:
		ordered_species.append(global.get_species(species_id))
	ordered_species.sort_custom(self, 'compare_by_species_id')
	return ordered_species

func compare_by_species_id(a: Species, b: Species):
	return a.species_id < b.species_id
	
