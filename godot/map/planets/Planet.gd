extends Resource

class_name Planet

export var id: String
export var name : String
export var tagline1 : String
export var tagline2 : String

export var species : Resource # SpeciesTemplate
export var description : String 
export var minigames : Array = [Object(), Object(), Object(), Object()]


var played_levels_1players : Array = []
var played_levels_2players : Array = []
var played_levels_3players : Array = []
var played_levels_4players : Array = []

export var planet_sprite : StreamTexture

export var game_mode : Resource # GameMode
export var this_game_mode : Resource # GameMode
export var mutators : Array = []

func shuffle_levels(num_players : int) -> void:
	minigames.shuffle()
	
func get_levels(num_players : int) -> Array:
	var levels = []
	for m in minigames:
		levels.append(m.get("levels_" + str(num_players) + "players"))
		
	return levels
	
func fetch_level(num_players : int) -> PackedScene:
	""" Get one level from their pool 
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
	"""
	
	return minigames[0].get("levels_" + str(num_players) + "players")
	
func locked_games():
	var ret = []
	for minigame in self.minigames:
		if not TheUnlocker.get_status_game(minigame.get_id()):
			ret.append(minigame)
	return ret
