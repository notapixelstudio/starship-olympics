extends Control

onready var container = $GridContainer

func get_player_hud(player_index:String):
	return container.get_node(player_index.to_upper())

func initialize(num_players:int):
	# hide who doesn't play
	for i in range(0,global.MAX_PLAYERS-num_players):
		var player = "p"+str(global.MAX_PLAYERS-i)
		get_player_hud(player.to_upper()).hide()
	
		
	show()
		
func _ready():
	visible = false
	
func _on_Arena_update_score(player_name:String, points:int, collectable_owner: String):
	var player_hud = get_player_hud(player_name)
	print(player_hud, " for player ", player_name)
	if collectable_owner:
		player_hud.set_collectables(points)
	else:
		player_hud.set_deaths(points)


