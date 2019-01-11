extends Control

onready var container = $GridContainer

func get_player_hud(player_index:String):
	return container.get_node(player_index.to_upper())

func initialize(players:Array):
	# hide who doesn't play
	var i = 0
	for player in players:
		assert(player is PlayerSpawner)
		container.get_node(player.name.to_upper()).show()
		
	
		
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


