extends Resource

class_name GameMode

export var id : String
export var name : String
export var icon : StreamTexture
export var arena_style : Resource = null
export var description : String
export var cpu_brain : PackedScene

export var max_timeout : int = 120
export var max_score: int = 100
export var starting_score : int = 0
export var cumulative: bool = false
export var shared_targets := true
export var starting_lives : int = -1
export var starting_health : int = 1
export var respawn_from_home := false
export var end_on_perfect := true
export var fill_starting_score := false
export var streaks_enabled := true

# goal manager
export var death : bool = false
export var last_man : bool = false
export var crown : bool = false
export var hive : bool = false
export var collect : bool = false
export var goal : bool = false
export var survival : bool = false
export var race: bool = false

# gear 
export var pursuing_bombs : bool = true 
export var shoot_bombs : bool = true setget set_bombs
export var deadly_trails : bool = false
export var deadly_trails_duration : float = 2.0
enum BOMB_TYPE { classic, ball, bullet, bubble, mine, ice, wave, fw_pew }
export(BOMB_TYPE) var bomb_type = BOMB_TYPE.classic
export var starting_ammo : int = -1
export var reload_time : float = 3.0
export var auto_thrust : bool = false
export var start_invincible := true

func set_bombs(value):
	shoot_bombs = value

# modifiers
export var floodable : bool = true
export var flood : bool = false
export var laserable : bool = false
export var additional_lasers : bool = false

func get_id():
	return id
	
func get_icon():
	return icon
	
func get_cpu_brain_scene() -> PackedScene:
	return cpu_brain
	
