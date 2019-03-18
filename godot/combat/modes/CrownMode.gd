extends Node

class_name CrownMode

const BASE_TIME_LEFT:float = 1.0
var time_left:float

const TARGET_SCORE:float = 4.0
var players:Array
var scores:Dictionary = {}
var queen = null

var game_over:bool = false

signal game_over

func initialize(_players: Array):
	scores = {}
	
	for player in _players:
		var team = player.species_template.species_name
		scores[team] = player
		
	time_left = BASE_TIME_LEFT + TARGET_SCORE*len(scores)
	
func crown_taken(ship):
	queen = ship
	ECM.E(queen).get('Royal').enable()
	print("CROWN TAKEN - Queen ship is now " + queen.species)
	
func crown_lost():
	ECM.E(queen).get('Royal').disable()
	queen = null
	print("CROWN LOST")
	
func is_there_a_queen():
	return queen != null
	
func update(delta:float):
	if game_over:
		return
		
	time_left -= delta
	
	if time_left < 0:
		var best_score = 0
		var best_player = null
		for player in scores:
			if scores[player].get_score() >= best_score:
				best_player = player
				best_score = scores[player].get_score()
		# print("Time's up. Game over. " + best_player + ' wins.')
		game_over = true
		emit_signal("game_over", best_player, scores)
		
	if queen != null:
		scores[queen.species]["score"] += delta
		
		if scores[queen.species].get_score() >= TARGET_SCORE:
			print(queen.species + " wins.")
			game_over = true
			emit_signal("game_over", queen.species, scores)
