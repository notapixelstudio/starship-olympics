extends Node

# single truth point
var local_multiplayer

const SETTINGS_FILENAME = "res://export.cfg"
const E = 2.71828

const isometric_offset = Vector2(0,32)

var enable_camera := true 

const SUIT_COLORS = {
	"blue": Color('#0080ff'),
	"red": Color('#ff3333'),
	"yellow": Color('#ffde5f'),
	"white": Color('#ffffff'),
	"cyan": Color('#00fff3'),
	'green': Color('#53ff53'),
	"magenta": Color('#d849f5'),
	'mystery': Color('#7c6989')
}

var enable_analytics : bool = false setget _set_analytics
signal send_statistics

func _set_analytics(new_value):
	if enable_analytics != new_value:
		if new_value:
			Analytics.enable()
		else:
			Analytics.disable()
	enable_analytics = new_value
	

#######################################
############# Controls ################
#######################################

var array_joypad_preset = ["default", "minimal"]
onready var joypad_preset

var array_keyboard_preset = ["custom", "everything", "minimal"]
onready var keyboard_preset

var array_keyboard_device = ["kb1", "kb2"]
onready var keyboard_device 
var array_joypad_device = ["joy1", "joy2", "joy3", "joy4"]
onready var joypad_device 

var array_custom_device = ["custom1"]
onready var custom_device 

var remotesServer

var ui_rightPressed = false
var ui_leftPressed  = false
var ui_upPressed    = false
var ui_downPressed  = false
	

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
		
	
onready var graphics_quality: String = "HD" setget _set_graphics_quality
var array_graphics_quality: Array = ["minimum", "low", "medium", "maximum", "HD"]

func _set_graphics_quality(value: String):
	# 16:9 aspect ratio resolutions: 1024×576, 1152×648, 1280×720, 1366×768, 1600×900, 1920×1080, 2560×1440 and 3840×2160.
	graphics_quality = value
	match graphics_quality:
		"low":
			set_stretch(Vector2(1024,576), 0.8)
		"medium":
			set_stretch(Vector2(1152,648), 0.9)
		"maximum":
			set_stretch(Vector2(1280,720), 1)
		"HD":
			set_stretch(Vector2(1280,720), 1, SceneTree.STRETCH_MODE_2D)
func set_stretch(resolution:Vector2, stretch:float, stretch_mode := SceneTree.STRETCH_MODE_VIEWPORT):
	get_tree().set_screen_stretch(stretch_mode,  SceneTree.STRETCH_ASPECT_KEEP, resolution, stretch)
	
func get_graphics_scale() -> Vector2:
	var viewport_size := get_tree().get_root().get_size()
	var world_size := Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	return viewport_size/world_size
	
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
	TranslationServer.set_locale(available_languages.get(language, "en"))

func _get_language():
	return language

var version = "0.14.4a5" setget set_version
var first_time = true

func set_version(value):
	print("Version is and will be {v}".format({"v": version}))


# OPTIONS need a min and a MAX
const min_win = 1
var win = 3
const max_win = 10

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
# playtest mode, fixed selection player
var demo_playtest : bool = false

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
enum Controls {KB1, KB2, JOY1, JOY2, JOY3, JOY4,RM1,RM2,RM3,RM4, NO, CPU}

const CONTROLSMAP = {
	Controls.NO : "no",
	Controls.CPU : "cpu",
	Controls.KB1 : "kb1",
	Controls.KB2 : "kb2",
	Controls.JOY1 : "joy1",
	Controls.JOY2 : "joy2",
	Controls.JOY3 : "joy3",
	Controls.JOY4 : "joy4",
	Controls.RM1 : "rm1",
	Controls.RM1 : "rm2",
	Controls.RM1 : "rm3",
	Controls.RM1 : "rm4",
}

const CONTROLSMAP_TO_KEY = {
	"no" : Controls.NO,
	"cpu" : Controls.CPU,
	"kb1" : Controls.KB1,
	"kb2" : Controls.KB2,
	"joy1" : Controls.JOY1,
	"joy2" : Controls.JOY2,
	"joy3" : Controls.JOY3,
	"joy4" : Controls.JOY4,
	"rm1" : Controls.RM1,
	"rm2" : Controls.RM2,
	"rm3" : Controls.RM3,
	"rm4" : Controls.RM4
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
	if demo and (event is InputEventJoypadButton or event is InputEventKey):
		demo = false
		reset_counts()
		Events.emit_signal('nav_to_character_selection')
		get_tree().paused = false
		
		
	if event.is_action_pressed("fullscreen"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		OS.window_fullscreen = not OS.window_fullscreen
	
	if demo_playtest and event.is_action_pressed("force_reset"):
		get_tree().change_scene("res://local_multiplayer/LocalMultiplayer.tscn")
		get_tree().paused = false
		reset_counts()
		
	if demo_playtest and event.is_action_pressed("delete_persistence"):
		persistance.delete_latest_game()

var installation_id 
func _ready():
	# we want to handle quit by ourselves
	get_tree().set_auto_accept_quit(false)
	
	print("Starting game...")
	
	
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_to_group("persist")
	
	remotesServer = preload("res://Server.tscn").instance()
	remotesServer.connect("remote_command_received",self,"_onRemoteCommand")	
	
	add_child(remotesServer)
		
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
	
func getRemotesServer():
	return remotesServer

	
func handleEvent(pressed,strength, event):
	var ev = InputEventAction.new()
	ev.action = event
	ev.pressed = pressed
	ev.strength = abs(strength)
	Input.parse_input_event(ev)

func handleEventAccept(cmd, event):
	var ev = InputEventAction.new()
	ev.action = event
	if cmd == "1" or cmd == "2":
		ev.pressed = true
	elif cmd == "0" or cmd == "3":
		ev.pressed = false
	# Feedback.
	Input.parse_input_event(ev)

func handleEventFire(cmd, event):
	var ev = InputEventAction.new()
	ev.action = event
	if cmd == "1" or cmd == "2":
		ev.pressed = true
	elif cmd == "0" or cmd == "3":
		ev.pressed = false
	# Feedback.
	Input.parse_input_event(ev)
		
func _onRemoteCommand(id,strength,button):
	#print("Received data: %s" % cmds)
	var controlsString = "rm" + str(id)
	var data = str2var(strength)
	if data[0] >= 0:
		handleEvent(true,data[0],controlsString + "_right")
		handleEvent(false,data[0],controlsString + "_left")
	else:
		handleEvent(false,data[0],controlsString + "_right")
		handleEvent(true,data[0],controlsString + "_left")

	if data[1] >= 0:
		handleEvent(true,data[1],controlsString + "_down")
		handleEvent(false,data[1],controlsString + "_up")
	else:
		handleEvent(false,data[1],controlsString + "_down")
		handleEvent(true,data[1],controlsString + "_up")

#		if data[0] >= 0.5:
#			if !ui_rightPressed:
#				handleEvent(true,data[0], "ui_right")
#				ui_rightPressed = true
#			ui_leftPressed = false
#
#		elif data[0] <= 0.5:
#			if !ui_leftPressed:
#				handleEvent(true,data[0],"ui_left")
#				ui_leftPressed = true
#			ui_rightPressed = false
#
#		if data[1] >= 0.5:
#			if !ui_downPressed:
#				handleEvent(true,data[1], "ui_down")
#				ui_downPressed = true
#			ui_upPressed = false
#
#		elif data[1] <= 0.5:
#			if !ui_upPressed:
#				handleEvent(true,data[1], "ui_up")		
#				ui_upPressed = true
#			ui_downPressed = false
			
		
	handleEventFire(button,controlsString + "_fire")
	handleEventAccept(button,"ui_accept")
	 
func create_dir(path: String):
	var dir = Directory.new()
	dir.make_dir_recursive(path)


func write_into_file(filepath: String, data: String, mode := File.READ_WRITE):
	#open the log file and go to the end
	var file = File.new()
	var error = file.open(filepath, mode)
	if error == ERR_FILE_NOT_FOUND:
		create_dir(filepath.get_base_dir())
		error = file.open(filepath, File.WRITE_READ)
	if error == OK:
		file.seek_end()
		file.store_line(data)
		file.flush() # WARNING writing to disk too often could hurt performance
		print(file.get_path_absolute())
		file.close()
	else: 
		print("FILE WITH ERROR {error_code}".format({"error_code": error }))
	
func read_file(path: String) -> String:
	# When we load a file, we must check that it exists before we try to open it or it'll crash the game
	var file = File.new()
	if not file.file_exists(path):
		print("The save file does not exist.")
		return ""
	file.open(path, File.READ)
	print("We are going to load from this JSON: ", file.get_path_absolute())
	# parse file data - convert the JSON back to a dictionary
	var data = ""
	data = file.get_as_text()
	file.close()
	return data

func read_file_by_line(path: String) -> Array:
	# When we load a file, we must check that it exists before we try to open it or it'll crash the game
	var file = File.new()
	if not file.file_exists(path):
		print("The file does not exist.")
		return []
	file.open(path, File.READ)
	print("We are going to load from this JSON: ", file.get_path_absolute())
	# parse file data - convert the JSON back to a dictionary
	var data = []
	var num_lines = 1
	while not file.eof_reached(): # iterate through all lines until the end of file is reached
		var content = file.get_line()
		if content == "":
			continue
		data.append(parse_json(content))
		num_lines += 1
	print("Read {lines}".format({"lines":num_lines}))
	file.close()
	return data

func install():
	installation_id = read_file("user://uuid").strip_edges()
	if not installation_id:
		installation_id=UUID.v4()
		write_into_file("user://uuid", installation_id, File.WRITE_READ)
		Events.emit_signal("analytics_event", {"id": installation_id}, "installation")
		
var execution_uuid : String
func start_execution():
	# this will ensure the explicit_consent
	global.first_time=false
	execution_uuid = UUID.v4()
	Events.emit_signal('execution_started')
	
func end_execution():
	# trigger quit
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	
func _notification(what):
	# actual quitting
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("Thanks for playing")
		Events.emit_signal('execution_ended')
		yield(get_tree().create_timer(1), "timeout")
		print("Closing everything")
		get_tree().quit() # default behavior

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
		full_screen=full_screen,
		graphics_quality=graphics_quality,
		rumbling=rumbling,
		glow_enable=glow_enable,
		enable_camera=enable_camera,
		flood=flood,
		time_scale=time_scale,
		laser=laser,
		sessions_played=sessions_played,
		shown_cards_from_deck=shown_cards_from_deck
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
	

func shake_node(node, tween):
	var actual_d_pos = node.rect_position
	tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position + Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_method(node, "set_position", node.rect_position + Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	tween.start()
	
	
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
	print("{saved_patch} < {patch} = {result_patch} or {saved_minor} < {minor} = {result_minor}".format({"saved_patch": int(saved_patch), "patch": int(patch), "saved_minor": saved_minor, "minor": minor, "result_patch":int(saved_patch) < int(patch) , "result_minor": int(saved_minor) < int(minor)}))
	return int(saved_patch) < int(patch) or int(saved_minor) < int(minor)

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
		if typeof(map[k]) == TYPE_ARRAY:
			for element in map[k]:
				ret[element] = k
		else:
			ret[map[k]] = k
	return ret


var glow_enable = true setget _set_glow

func _set_glow(value):
	glow_enable = value
	Events.emit_signal("glow_setting_changed")
	

# GAMEPLAY
var the_game: TheGame = null
var the_match: TheMatch = null
var session: TheSession = null
var arena

func reset_counts():
	game_number = 0
	session_number = 0
	sessions_played = 0 # Total number of sessions. Persistence
	session_number_of_game = 0
	match_number_of_game = 0
	match_number_of_session = 0
	reset_minigame_counts()
	
func reset_minigame_counts():
	if is_game_running():
		for card in the_game.all_cards.get_cards():
			var minigame = (card as DraftCard).get_minigame()
			if minigame:
				minigame.reset_count()
	
var game_number := 0
var session_number := 0
var sessions_played := 0 # Total number of sessions. Persistence
var session_number_of_game := 0
var match_number_of_game := 0
var match_number_of_session := 0

var game_started_ms : int

func new_game(players: Array, data := {}) -> TheGame:
	safe_destroy_game()
	game_started_ms = OS.get_ticks_msec()
	the_game = TheGame.new()
	game_number += 1
	the_game.set_players(players)
	var deck := Deck.new()
	if not data.empty():
		the_game.set_from_dictionary(data)
		deck.set_from_dictionary(data.get("deck"))
	else:
		deck.setup()
	the_game.set_deck(deck)
	Events.emit_signal("game_started")
	for player in players:
		var selection_event_data = (player as InfoPlayer).to_dict()
		selection_event_data.game_id=global.the_game.get_uuid()
		Events.emit_signal("analytics_event", selection_event_data, "player_selected")
	return the_game

var match_started_ms: int
func new_match() -> TheMatch:
	safe_destroy_match()
	match_started_ms = OS.get_ticks_msec()
	the_match = TheMatch.new()
	match_number_of_game += 1
	match_number_of_session += 1
	print("Save the game")
	if not global.demo:
		persistance.save_game_as_latest()
	return the_match
	
var session_started_ms : int
func new_session(existing_data := {}) -> TheSession:
	safe_destroy_session()
	session_started_ms = OS.get_ticks_msec()
	session = TheSession.new()
	session_number_of_game += 1
	
	# whenever a new session is created, InfoPlayer stats should be cleared. 
	# Unless we are loading a existing session
	if existing_data.empty():
		the_game.reset_players()
	
	var deck: Deck = the_game.get_deck()
	
	var hand_ids : Array = existing_data.get("hand", [])
	var hand := []
	if existing_data.get("playing_card"):
		var playing_card_id = existing_data.get("playing_card")
		hand.append(deck.get_card(playing_card_id))
	for card_id in hand_ids:
		hand.append(deck.get_card(card_id))
	
	session.set_hand(hand)
	session.setup_from_dictionary(existing_data)
	Events.emit_signal('session_started')
	
	return session

func safe_destroy_game() -> void:
	if is_game_running():
		# also delete the session
		safe_destroy_session()
		
		Events.emit_signal("game_ended")
		the_game.free()
	the_game = null
	session_number_of_game = 0
	match_number_of_game = 0
	
func safe_destroy_match() -> void:
	if is_match_running():
		Events.emit_signal("match_ended", the_match.to_dict())
		the_match.free()
	the_match = null
	
func safe_destroy_session() -> void:
	if is_session_running():
		# also delete the match
		safe_destroy_match()
		
		# put back cards into the deck
		session.discard_hand()
		Events.emit_signal("session_ended")
		session.free()
	session = null
	match_number_of_session = 0
	
func is_game_running() -> bool:
	return the_game != null and is_instance_valid(the_game)
	
func is_match_running() -> bool:
	return the_match != null and is_instance_valid(the_match)
	
func is_session_running() -> bool:
	return session != null and is_instance_valid(session)
	
func is_before_first_match_of_the_game() -> bool:
	return match_number_of_game == 0
	
func is_before_first_match_of_the_session() -> bool:
	return match_number_of_session == 0

# remember which cards have already been shown to the player and in which starting deck
var shown_cards_from_deck := {}

func has_card_been_shown_from_deck(card_id : String, starting_deck_id : String) -> bool:
	return shown_cards_from_deck.has(starting_deck_id) and shown_cards_from_deck[starting_deck_id].has(card_id)
	
func has_any_card_been_shown_from_deck(starting_deck_id : String) -> bool:
	return shown_cards_from_deck.has(starting_deck_id)
	
func add_card_to_shown_cards(card_id : String, starting_deck_id : String) -> void:
	if not shown_cards_from_deck.has(starting_deck_id):
		shown_cards_from_deck[starting_deck_id] = {}
	shown_cards_from_deck[starting_deck_id][card_id] = true
	
func reset_shown_cards_from_deck() -> void:
	shown_cards_from_deck = {}
	
###############################
##### FILE SYSTEM UTILS #######
###############################
const SPECIES_PATH = "res://selection/characters"
const DECK_PATH = "res://map/draft/decks/"

func get_resources(base_path: String) -> Dictionary:
	var ret := {}
	var resources = global.dir_contents(base_path, "", ".tres")
	for filename in resources:
		var this_res = load(base_path.plus_file(filename))
		var res_id = this_res.get_id()
		ret[res_id] = this_res
	return ret

onready var species_resources: Dictionary = get_resources(SPECIES_PATH)
func get_species(species_id: String):
	return species_resources[species_id]

func get_actual_resource(resource_list: Dictionary, resource_id: String):
	return resource_list[resource_id]
	
func get_ordered_species() -> Array:
	var ordered_species = []
	var unlocked_species = TheUnlocker.get_unlocked_list("species")
	for species_id in unlocked_species:
		ordered_species.append(global.get_species(species_id))
	ordered_species.sort_custom(self, 'compare_by_species_id')
	return ordered_species

func compare_by_species_id(a: Species, b: Species):
	return a.species_id < b.species_id
	
var starting_deck_id: String = "first"


# Date utils
func datetime_to_str(datetime: Dictionary, use_local := false) -> String:
	# {"day":23,"dst":false,"hour":18,"minute":41,
	# "month":9,"second":55,"weekday":4,"year":2021}
	# FIXME replace with ISO dates
	var tz = Time.get_time_zone_from_system()
	var tz_hours = floor(tz.bias / 60)
	var tz_min = floor(tz.bias%60)
	var datetime_with_local := datetime
	var local_tz = ""
	datetime.erase("second")
	var datetime_string = Time.get_datetime_string_from_datetime_dict(datetime, true)
	if use_local:
		datetime["hour"] = datetime["hour"] + tz_hours
		datetime["minute"] = datetime["hour"] + tz_hours
		datetime_string = Time.get_datetime_string_from_datetime_dict(datetime, true)
		local_tz = Time.get_offset_string_from_offset_minutes(tz.bias)
	return datetime_string

func get_playlist_starting_deck(list_of_status: Array):
	#  = TheUnlocker.UNLOCKED
	var decks: Dictionary = global.get_resources(global.DECK_PATH)
	var playlists = []
	for starting_deck in decks.values():
		assert(starting_deck is StartingDeck)
		if starting_deck.is_playlist():
			if TheUnlocker.get_status("starting_decks", starting_deck.get_id()) in list_of_status:
				playlists.append(starting_deck)
	return playlists
