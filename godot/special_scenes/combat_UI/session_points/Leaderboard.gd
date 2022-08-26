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
	
	var players = global.the_game.get_players()
	var last_match = global.session.get_last_match()
	var winners = last_match.get("winners")
	
	for winner in winners:
		print("%s won" % [winner.id])
		assert(winner is InfoPlayer)
		winner.add_victory(last_match.get("winners_did_perfect"))
		
	var max_points = global.win # Points of the session
	# sorted before and sorted after
	var i = 0
	for player in players:
		var pilot_stats = pilot_stats_scene.instance()
		pilot_stats.max_points = max_points
		pilot_stats.position = pad*i
		container.add_child(pilot_stats)
		
		if player in winners:
			pilot_stats.just_won = true
		pilot_stats.set_info(player)
		i+=1
		
	animator.play("entrance")
	
func celebrate():
	var session_winners = global.the_game.get_last_winners()
	
	for pilot in container.get_children():
		if pilot.info in session_winners:
			# this is a session winner
			pilot.celebrate()
