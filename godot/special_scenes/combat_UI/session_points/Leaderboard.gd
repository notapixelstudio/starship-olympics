extends MarginContainer

const pad = Vector2(0, 130)

export var pilot_stats_scene : PackedScene 

onready var animator = $AnimationPlayer
onready var container = $Chart

func initialize(winners: Array):
	"""
	Parameters
	----------
	winners : Array of PlayerStats
	
	"""
	var the_match = global.the_match
	var sport = the_match.sport
	var players = the_match.players
	for winner in winners:
		winner.add_victory(winner.score >= the_match.target_score) # sets the perfect flag
		
	var scores = the_match.player_scores
	var max_points = global.win # Points of the session
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
		global.send_stats("design", {"event_id": "gameplay:sport:{sport}:lasting_time".format({"sport": sport.name}), "value": the_match.lasting_time}) 
	
	animator.play("entrance")
	
	if not TheUnlocker.is_map_unlocked():
		TheUnlocker.will_unlock()
