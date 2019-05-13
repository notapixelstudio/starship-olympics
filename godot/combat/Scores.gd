extends Node
# This script handles scores and in-game stats

class_name Scores

const BASE_TIME_LEFT:float = 40.0
var time_left:float

const TARGET_SCORE:float = 40.0

var scores_index:Dictionary = {}
var scores:Array

var draw: bool = true
var game_over:bool = false

signal game_over

func initialize(_players: Array, max_timeout: int = 120):
	scores = []
	scores_index = {}
	
	for player in _players:
		player.start()
		var team = player.species_template.species_name
		if not team in scores_index:
			scores_index[team] = player
			scores.append(scores_index[team])
		
	time_left = min(BASE_TIME_LEFT + TARGET_SCORE*len(scores), max_timeout)
	
func sort_scores():
	scores.sort_custom(self, 'score_cmp')
	
func score_cmp(a, b):
	return a["score"] > b["score"]
	
func update(delta:float):
	if game_over:
		return
		
	time_left -= delta
	time_left = max(0, time_left)
	sort_scores()
	
	var leader = scores[0]
	
	
	if leader["score"] >= TARGET_SCORE or time_left <= 0:
		var draw = true
		var last_value = leader["score"]
		for player in scores:
			if last_value == player["score"]:
				draw = true
			else:
				draw = false
		var winner = leader["species"]
		if draw:
			winner = "noone"
		print('Game Over - ', winner, ' won.')
		game_over = true
		emit_signal("game_over", winner, scores_index)
		
func add_score(team : String, amount : float):
	assert team in scores_index
	scores_index[team]["score"] = max(0, scores_index[team]["score"] + amount)

func update_stats(team: String, amount: int, stat: String):
	# TODO: make it work for team
	var info_player : InfoPlayer = scores_index[team]
	var stat_value = info_player.get(stat)
	info_player.set(stat, stat_value + amount)