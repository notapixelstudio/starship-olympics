extends MarginContainer

const pad = Vector2(0, 130)

export var pilot_stats_scene : PackedScene 

onready var animator = $AnimationPlayer
onready var container = $Chart

func initialize(winners: Array, match_scores):
	"""
	Parameters
	----------
	winners : Array of PlayerStats
	match_scores: MatchScores object for this match
		
	"""
	var sport = match_scores.sport
	var players = match_scores.players
	for winner in winners:
		players[winner.id].add_victory()
		winner.add_victory()
		
	var scores = match_scores.scores
	var max_points = global.win
	# sorted before and sorted after
	var i = 0
	for stats in scores:
		var pilot_stats = pilot_stats_scene.instance()
		pilot_stats.max_points = max_points
		pilot_stats.position = pad*i
		container.add_child(pilot_stats)
		
		if stats in winners:
			pilot_stats.just_won = true
		pilot_stats.info = stats
		i+=1

		var json_stats = stats.to_stats()
		
		# SEND STATISTICS
		for key in json_stats:
			global.send_stats("design", {"event_id": "gameplay:{sport}:{key}:{id}".format({"sport":sport.name, "key": key, "id": stats.id}), "value": json_stats[key]}) 
		for winner in winners:
			global.send_stats("design", {"event_id": "gameplay:sport:{sport}:won:{id}".format({"sport": sport.name, "id": winner.id})}) 
		global.send_stats("design", {"event_id": "gameplay:sport:{sport}:lasting_time".format({"sport": sport.name}), "value": match_scores.lasting_time}) 
	
	animator.play("entrance")
	
	"""
	yield(animator, "animation_finished")
	var players = container.get_children()
	players.sort_custom(self, "sort_by_score")
	for player in players:
		player.new_position = pad * i
		i += 1
	

func sort_by_score(a: PilotStats, b: PilotStats):
	return a.get_player_info().session_score > b.get_player_info().session_score
"""
