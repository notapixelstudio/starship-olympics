extends Resource

class_name Planet

export var name : String
export var tagline1 : String
export var tagline2 : String

export var species : Resource # SpeciesTemplate

export var levels_2players : Array
export var levels_3players : Array
export var levels_4players : Array


func get_levels(num_players : int) -> Array:
    return get("levels_" + str(num_players) + "players")
