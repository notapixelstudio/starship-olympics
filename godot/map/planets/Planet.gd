extends Resource

class_name Planet

export var name : String
export var tagline1 : String
export var tagline2 : String

export var species : Resource # SpeciesTemplate

export var levels_1players : Array
export var levels_2players : Array
export var levels_3players : Array
export var levels_4players : Array

var played_levels_1players : Array = []
var played_levels_2players : Array = []
var played_levels_3players : Array = []
var played_levels_4players : Array = []

export var planet_sprite : StreamTexture
export var planet_active_sprite : StreamTexture

export var game_mode : Resource # GameMode
export var this_game_mode : Resource # GameMode
export var mutator : Resource # GameMode

func shuffle_levels(num_players : int) -> void:
	levels_1players.shuffle()
	levels_2players.shuffle()
	levels_3players.shuffle()
	levels_4players.shuffle()
	get("levels_" + str(num_players) + "players").shuffle()
	
func get_levels(num_players : int) -> Array:
	return get("levels_" + str(num_players) + "players")

func fetch_level(num_players : int) -> PackedScene:
	""" Get one level from their pool """
	var levels = get("levels_" + str(num_players) + "players")
	var played_levels = get("played_levels_" + str(num_players) + "players")
	var current_level = levels[len(played_levels)].instance()
	played_levels.append(current_level)
	current_level.planet_name = name
	print("shoot bombs is ", game_mode.shoot_bombs, ". And for current level : ", current_level.game_mode.shoot_bombs)
	current_level.game_mode = game_mode.duplicate()
	
	if len(played_levels) >= len(levels):
		set("played_levels_" + str(num_players) + "players", [])
		levels.shuffle()
		
		# do not repeat the same level twice in a row
		if current_level == levels[0]:
			played_levels.append(levels[0])
			
	return current_level
	
