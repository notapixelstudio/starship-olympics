extends MarginContainer

const pad = Vector2(0, 130)

export var pilot_stats_scene : PackedScene 

onready var animator = $AnimationPlayer
onready var container = $Chart

func _ready():
	"""
	Parameters
	----------
	winners : Array of PlayerStats
	
	"""
	
	var players = global.the_match.players
	for winner in global.the_match.winners:
		assert(winner is InfoPlayer)
		winner.add_victory(winner.get_score() >= global.the_match.target_score) # sets the perfect flag
		
	var max_points = global.win # Points of the session
	# sorted before and sorted after
	var i = 0
	for player in global.the_match.player_scores:
		var pilot_stats = pilot_stats_scene.instance()
		pilot_stats.max_points = max_points
		pilot_stats.position = pad*i
		container.add_child(pilot_stats)
		
		if player in global.the_match.winners:
			pilot_stats.just_won = true
		pilot_stats.set_info(player)
		i+=1
		
	animator.play("entrance")
	
	if not TheUnlocker.is_map_unlocked():
		TheUnlocker.will_unlock()
