extends Control

onready var container = $GridContainer

var game_mode

func get_player_hud(player_index:String):
	return container.get_node(player_index.to_upper())

func initialize(mode):
	game_mode = mode
	
	var num_players = len(game_mode.scores)
	
	# hide who doesn't play
	for i in range(0,global.MAX_PLAYERS-num_players):
		var player = "p"+str(global.MAX_PLAYERS-i)
		get_player_hud(player.to_upper()).hide()
	
		
	show()
		
func _ready():
	visible = false
	
func _on_Arena_update_score(player_name:String, points:int, collectable_owner: String):
	var player_hud = get_player_hud(player_name)
	if collectable_owner:
		player_hud.set_collectables(points)
	else:
		player_hud.set_deaths(points)


func _process(delta):
	get_player_hud('P1').set_collectables(game_mode.time_left)
	
	get_player_hud('P1').set_deaths(game_mode.scores['p1'])
	get_player_hud('P2').set_deaths(game_mode.scores['p2'])
	