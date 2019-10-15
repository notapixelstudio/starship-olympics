extends Node
# This script handles scores and in-game stats

class_name Scores

var time_left:float

var target_score: float = 100

var scores_index:Dictionary = {}
var scores:Array

var draw: bool = true
var game_over:bool = false
var cumulative_points = 0

signal game_over
func start():
	set_process(true)

func stop():
	set_process(false)

func initialize(_players: Array, game_mode: GameMode, max_score: float = 0):
	scores = []
	scores_index = {}
	target_score = game_mode.max_score
	if max_score:
		target_score = max_score
	
	cumulative_points = -1
	
	for player in _players:
		player.start()
		var team = player.species_template.species_name
		if not team in scores_index:
			scores_index[team] = player
			scores.append(scores_index[team])
		
	time_left = game_mode.max_timeout
	if game_mode.cumulative:
		cumulative_points=0
	stop()
	
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
	
	if leader["score"] >= target_score or time_left <= 0 or (cumulative_points>=target_score):
		print(" CI SIAMOOOOOO: ", str(cumulative_points), " vs ", str(target_score))
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
	
	if cumulative_points >= 0:
		cumulative_points += amount
		
func get_score(team : String):
	return scores_index[team]["score"]
	
func broadcast_score(team : String, amount : float):
	assert team in scores_index
	for team_player in scores_index:
		if team_player != team:
			add_score(team_player, amount)


func update_stats(team: String, amount: int, stat: String):
	# TODO: make it work for team
	var info_player : InfoPlayer = scores_index[team]
	var stat_value = info_player.get(stat)
	info_player.set(stat, stat_value + amount)