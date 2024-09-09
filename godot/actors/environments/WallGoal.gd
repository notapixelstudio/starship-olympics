extends StaticBody2D

class_name WallGoal


@export var goal_owner : NodePath

var player : get = get_player, set = set_player

signal goal_done(ship, goal)

func set_player(v : InfoPlayer):
	player = v
	modulate = player.species.color
	
func get_player():
	return player
	
func _ready():
	var player_spawner = get_node(goal_owner)
	if player_spawner:
		await player_spawner.player_assigned
		set_player(player_spawner.get_player())
	
func get_score():
	return 1
	
func do_goal(author, position):
	emit_signal('goal_done', author, self, position)
	
func get_strategy(ship, distance, game_mode):
	if game_mode.get_id() == 'ponganoid':
		if get_player().team != ship.get_player().team:
			return {'seek': 1}
	
	return {}
