extends Control

var player

func initialize(color, max_value):
	$ProgressBar.modulate = color
	$ProgressBar.max_value = max_value
	
func set_value(value):
	$ProgressBar.value = value
	