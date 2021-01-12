extends Manager

class_name ModeManager

export var score_multiplier: float = 1

func _ready():
	set_process(enabled)

func score(id_player: String, amount : float, broadcasted = false):
	global.the_match.add_score(id_player, amount, broadcasted)
