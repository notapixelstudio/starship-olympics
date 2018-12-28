extends Control

func _ready():
	var num_players = 4
	for i in range(0,4-num_players):
		get_node("GridContainer/P"+str(4-i)).hide()



func _on_Arena_update_score(player_name):
	get_node("GridContainer/"+str(player_name.to_upper())).get_scores()
	