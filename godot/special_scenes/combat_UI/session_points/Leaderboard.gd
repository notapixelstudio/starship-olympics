extends MarginContainer

const line_height = 140

@export var pilot_stats_scene : PackedScene 
@export var players : Array[Player] : set = set_players
@export var max_session_score := 3 # default: classic session
@export var session_scores : Dictionary # {team: points}

signal animation_over

	
	#var player_index = global.the_game.get_player_index()
	#var match_played = global.the_match
	#global.session.update_scores(match_played)
	
	#var winners = match_played.winners
	#var previous_leaderboard = global.session.get_previous_leaderboard()
	
	#var max_points = global.win # Points of the session
	# sorted before and sorted after
	#var i = 0
	#for player_dict in previous_leaderboard:
	#	var player : InfoPlayer = player_index[player_dict["id"]]
	#	var pilot_stats = pilot_stats_scene.instantiate()
	#	pilot_stats.max_points = max_points
	#	pilot_stats.position = pad*i
	#	container.add_child(pilot_stats)
		
	#	if player in winners:
	#		pilot_stats.just_won = true
	#	pilot_stats.set_info(player)
	#	i+=1
	
func set_players(v: Array[Player]) -> void:
	players = v
	if not is_inside_tree():
		await self.ready
		
	# empty container
	for child in %Container.get_children():
		child.queue_free()
		
	var i := 0
	for player in players:
		var pilot_stats = pilot_stats_scene.instantiate()
		pilot_stats.set_player(player)
		pilot_stats.set_max_session_score(max_session_score)
		pilot_stats.set_session_score(session_scores.get(player.get_team()))
		pilot_stats.position.y = line_height*i
		%Container.add_child(pilot_stats)
		i+=1
		

#	%AnimationPlayer.play("entrance")
	
	
func reorder():
	pass
	#var current_leaderboard = global.session.get_current_leaderboard()
	#var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	#for pilot_stat in %Container.get_children():
	#	var i = 0
	#	for player_dict in current_leaderboard:
	#		if player_dict["id"] == pilot_stat.info.get_id():
	#			tween.parallel().tween_property(pilot_stat, 'position:y', pad.y*i, 1.0)
	#		i += 1
			
	#await tween.finished
	#emit_signal("animation_over")
	#if global.session and global.session.is_over():
	#	celebrate()
	
func celebrate():
	var session_winners = global.the_game.get_last_winners()
	for pilot in %Container.get_children():
		if pilot.info in session_winners:
			# this is a session winner
			pilot.celebrate()
