extends Control

onready var progressbar = $ProgressBar
var player

func initialize(color, max_value):
	progressbar.modulate = color
	progressbar.max_value = max_value
	
func set_value(value):
	progressbar.value = value
	