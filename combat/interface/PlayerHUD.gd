extends MarginContainer

class_name PlayerHUD

onready var player = $NinePatchRect/Container/Label
onready var score = $NinePatchRect/Container/LivesCounter

func _ready():
	set_player_label()

func set_player_label():
	var player_text = name.replace("p".to_upper() , "Player ")
	player.text = player_text
	
func get_scores():
	pass
	
func set_score(points:int):
	score.set_score(points)
