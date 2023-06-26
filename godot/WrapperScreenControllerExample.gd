extends Control

func _ready():
	var difficulty_screen = load("res://ScreenDifficulty.tscn")
	$ScreenController.navigate_to(difficulty_screen)
	

