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

# goal manager
export var death : bool = false
export var crown : bool = false
export var hive : bool = false
export var collect : bool = false
export var flowsnake : bool = false
export var goal : bool = false

# gear 
export var shoot_bombs : bool = true setget set_bombs
export var deadly_trails : bool = false

func set_bombs(value):
	shoot_bombs = value


