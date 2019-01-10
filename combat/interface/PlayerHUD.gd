extends MarginContainer

class_name PlayerHUD

onready var player = $NinePatchRect/Container/Label
onready var deaths = $NinePatchRect/Container/Deaths
onready var collectables = $NinePatchRect/Container/Collectables

func _ready():
	set_player_label()

func set_player_label():
	var player_text = name.replace("p".to_upper() , "Player ")
	player.text = player_text
	
func get_scores():
	pass
	
func set_collectables(points:int):
	collectables.set_score(points)

func set_deaths(points:int):
	deaths.set_score(points)