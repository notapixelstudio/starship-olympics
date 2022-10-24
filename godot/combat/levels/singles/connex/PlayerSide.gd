extends Node2D

export var side_owner : NodePath
var player = null

var enabled := true

func _ready():
	var player_spawner = get_node(side_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
	else:
		set_player(null)
		
func set_player(v : InfoPlayer):
	player = v
	if player != null:
		$ColorBand.modulate = player.species.color
		$'%PlayerLabel'.text = player.get_username().to_upper()
		$'%PlayerLabel'.modulate = player.species.color
	
func get_player():
	return player
