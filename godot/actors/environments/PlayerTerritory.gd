extends Area2D

export var goal_owner : NodePath
var player

func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		yield(player_spawner, "player_assigned")
		set_player(player_spawner.get_player())
		
	$Polygon2D.polygon = $CollisionPolygon2D.polygon
	
func set_player(v : InfoPlayer):
	player = v
	$'%PlayerLabel'.text = player.get_username().to_upper()
	$'%PlayerLabel'.modulate = player.species.color
	$Polygon2D.modulate = player.species.color
	
func get_player():
	return player
