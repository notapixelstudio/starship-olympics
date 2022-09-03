extends MarginContainer

const pad = Vector2(0, 140)

export var pilot_stats_scene : PackedScene 

onready var animator = $AnimationPlayer
onready var container = $Chart

func _ready():
	"""
	Parameters
	----------
	winners : Array of PlayerStats
	
	"""
	global.safe_destroy_match()
	
	var player_index = global.the_game.get_player_index()
	global.session.update_stars()
	var winners = global.session.get_last_winners()
	var previous_leaderboard = global.session.get_previous_leaderboard()
	
	var max_points = global.win # Points of the session
	# sorted before and sorted after
	var i = 0
	for player_dict in previous_leaderboard:
		var player : InfoPlayer = player_index[player_dict["id"]]
		var pilot_stats = pilot_stats_scene.instance()
		pilot_stats.max_points = max_points
		pilot_stats.position = pad*i
		container.add_child(pilot_stats)
		
		if player in winners:
			pilot_stats.just_won = true
		pilot_stats.set_info(player)
		i+=1
		
	animator.play("entrance")
	
func reorder():
	var current_leaderboard = global.session.get_current_leaderboard()
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	for pilot_stat in container.get_children():
		var i = 0
		for player_dict in current_leaderboard:
			if player_dict["id"] == pilot_stat.info.get_id():
				tween.parallel().tween_property(pilot_stat, 'position:y', pad.y*i, 1.0)
			i += 1
			
	yield(tween, "finished")
	
	if global.session.is_over():
		celebrate()
	
func celebrate():
	var session_winners = global.the_game.get_last_winners()
	for pilot in container.get_children():
		if pilot.info in session_winners:
			# this is a session winner
			pilot.celebrate()
