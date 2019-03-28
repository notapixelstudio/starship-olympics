extends Node2D

class_name Bar

onready var progressbar = $ProgressBar
var player
var new_position setget change_position

func initialize(color, max_value):
	progressbar.modulate = color
	progressbar.max_value = max_value
	
func set_value(value):
	progressbar.value = value

func get_value():
	return progressbar.value

func change_position(new_value):
	new_position = new_value
	if position != new_position and not $Tween.is_active():
		$Tween.interpolate_property(self, "position", self.position, new_position, 0.5, 
			Tween.TRANS_CUBIC, Tween.EASE_IN, 0)
		$Tween.start()
	
