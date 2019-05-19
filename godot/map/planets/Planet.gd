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

export var game_mode : Resource # GameMode
export var secondary_game_mode : Resource # GameMode
export var mutator : Resource # GameMode

func get_levels(num_players : int) -> Array:
    return get("levels_" + str(num_players) + "players")

func fetch_level(num_players : int) -> PackedScene:
	""" Get one level from their pool """
	var levels = get("levels_" + str(num_players) + "players")
	var played_levels = get("played_levels_" + str(num_players) + "players")
	
	var current_level = levels[len(played_levels)]
	played_levels.append(current_level)
	
	if len(played_levels) >= len(levels):
		set("played_levels_" + str(num_players) + "players", [])
		levels.shuffle()
		
		# do not repeat the same level twice in a row
		if current_level == levels[0]:
			played_levels.append(levels[0])
			
	return current_level
	