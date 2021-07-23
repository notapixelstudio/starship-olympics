extends Resource

class_name Set

export var id: String
export var name : String
export var tagline1 : String
export var tagline2 : String

export var species : Resource # SpeciesTemplate
export var description : String 
export var minigames : Array = [Object(), Object(), Object(), Object()]

export var planet_sprite : StreamTexture

export var game_mode : Resource # GameMode
export var this_game_mode : Resource # GameMode
export var mutators : Array = []

func shuffle_levels(num_players : int) -> void:
	minigames.shuffle()
	
func get_minigames():
	return minigames.duplicate()

func get_id() -> String:
	return id
	
