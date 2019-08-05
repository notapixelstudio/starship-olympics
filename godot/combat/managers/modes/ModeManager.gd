extends Manager

class_name ModeManager

export var enabled : bool = true
export var score_multiplier: float = 1

func _ready():
	set_process(enabled)
		