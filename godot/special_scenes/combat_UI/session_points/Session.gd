extends MarginContainer

const pad = Vector2(0, 130)

export var player_stats_scene : PackedScene 

onready var animator = $AnimationPlayer
onready var container = $Chart

func initialize(scores, winners: Array, max_points = 3):
	# sorted before and sorted after
	var i = 0
	for player in scores:
		var player_stats = player_stats_scene.instance()
		player_stats.max_points = max_points
		player_stats.position = pad*i
		container.add_child(player_stats)
		
		if (player as InfoPlayer).id in winners:
			player_stats.just_won = true
		player_stats.player_info = player
		player_stats.name = player.species
		i+=1
		
	
	animator.play("entrance")
	yield(animator, "animation_finished")
	
	i = 0
	var players = container.get_children()
	players.sort_custom(self, "sort_by_score")
	for player in players:
		player.new_position = pad * i
		i += 1
	

func sort_by_score(a: PilotStats, b: PilotStats):
	return a.get_player_info().session_score > b.get_player_info().session_score
