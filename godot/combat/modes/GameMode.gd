extends Resource

class_name GameMode

export var is_mutator: bool = false
export var name : String
export var icon : StreamTexture
export var logo: StreamTexture
export var description : String
export var tagline_pro : String
export var tagline_cons : String
export var max_timeout : int = 120
export var max_score: int = 100
export var cumulative: bool = false
export var starting_lives : int = -1

# goal manager
export var death : bool = false
export var crown : bool = false
export var hive : bool = false
export var collect : bool = false
export var goal : bool = false
export var survival : bool = false

# gear 
export var shoot_bombs : bool = true setget set_bombs
export var deadly_trails : bool = false
export var deadly_trails_duration : float = 2.0
enum BOMB_TYPE { classic, ball }
export(BOMB_TYPE) var bomb_type = BOMB_TYPE.classic
export var starting_ammo : int = -1
export var reload_time : float = 3.0

func set_bombs(value):
	shoot_bombs = value

# modifiers
export var floodable : bool = true
export var flood : bool = false
export var laserable : bool = false
export var additional_lasers : bool = false
