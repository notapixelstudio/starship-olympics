extends Node

class_name Scores

const BASE_TIME_LEFT:float = 40.0
var time_left:float

const TARGET_SCORE:float = 40.0

var scores_index:Dictionary = {}
var scores:Array

var game_over:bool = false

signal game_over

func initialize(_players: Array):
	scores = []
	scores_index = {}
	
	for player in _players:
		player.start()
		var team = player.species_template.species_name
		if not team in scores_index:
			scores_index[team] = player
			scores.append(scores_index[team])
		
	time_left = BASE_TIME_LEFT + TARGET_SCORE*len(scores)
	
func sort_scores():
	scores.sort_custom(self, 'score_cmp')
	
func score_cmp(a, b):
	return a["score"] > b["score"]
	
func update(delta:float):
	if game_over:
		return
		
	time_left -= delta
	
	sort_scores()
	
	var leader = scores[0]
	
	if leader["score"] >= TARGET_SCORE or time_left < 0:
		print('Game Over - ', leader["species"], ' won.')
		game_over = true
		emit_signal("game_over", leader["species"], scores_index)
		
func add_score(team : String, amount : float):
	assert team in scores_index
	
	scores_index[team]["score"] = max(0, scores_index[team]["score"] + amount)
	