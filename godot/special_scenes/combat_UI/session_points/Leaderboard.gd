extends MarginContainer

const line_height = 140

@export var pilot_stats_scene : PackedScene 
@export var players : Array[Player] : set = set_players
@export var max_session_score := 3  : set = set_max_session_score # default: classic session
@export var session_scores : Dictionary : set = set_session_scores # {team: points}
@export var match_winners : Array[String] : set = set_match_winners # team

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
	
func set_players(v:Array[Player]) -> void:
	players = v
	_refresh()
	
func set_max_session_score(v:int) -> void:
	max_session_score = v
	_refresh()
	
func set_session_scores(v:Dictionary) -> void:
	session_scores = v
	_refresh()
	
func set_match_winners(v:Array[String]) -> void:
	match_winners = v
	_refresh()
	
func _refresh() -> void:
	if not is_inside_tree():
		await self.ready
		
	# set size
	custom_minimum_size.y = line_height * len(players) + 60 # margin handling
	
	# empty container
	for child in %Container.get_children():
		child.queue_free()
		
	var i := 0
	for player in players:
		var pilot_stats = pilot_stats_scene.instantiate()
		pilot_stats.set_player(player)
		pilot_stats.set_max_points(max_session_score)
		pilot_stats.set_points(session_scores.get(player.get_team()))
		pilot_stats.set_new_points(1 if player.get_team() in match_winners else 0)
		pilot_stats.position.y = line_height*i
		%Container.add_child(pilot_stats)
		i+=1
		

#	%AnimationPlayer.play("entrance")
	
	
func reorder():
	#var current_leaderboard = global.session.get_current_leaderboard()
	var leaderboard : Array[Dictionary] = []
	for player in players:
		leaderboard.append({'player': player, 'score': session_scores.get(player.get_team())})
		
	leaderboard.sort_custom(func(a,b): return a['score'] > b['score'])
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	for pilot_stat in %Container.get_children():
		var i = 0
		for player_dict in leaderboard:
			if player_dict['player'].get_id() == pilot_stat.get_player().get_id():
				tween.parallel().tween_property(pilot_stat, 'position:y', line_height*i, 1.0)
			i += 1
			
	await tween.finished
	#emit_signal("animation_over")
	#if global.session and global.session.is_over():
	_celebrate()
	
func _celebrate():
	#var session_winners = global.the_game.get_last_winners()
	for pilot in %Container.get_children():
		if pilot.get_player().get_team() in match_winners: # FIXME this is good only for standalone!
			# this is a session winner
			pilot.celebrate()
