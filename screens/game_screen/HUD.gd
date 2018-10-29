extends Control

func _ready():
	var num_players = len(global.scores)
	for i in range(0,4-num_players):
		get_node("GridContainer/P"+str(4-i)).hide()

