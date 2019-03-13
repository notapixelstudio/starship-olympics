extends Node

class_name CrownMode

const BASE_TIME_LEFT:float = 1.0
var time_left:float

const TARGET_SCORE:float = 1.0
var players:Array
var scores:Dictionary = {}
var queen = null

var game_over:bool = false

signal game_over

func initialize(_players:Array):
	players = _players
	
	for player in players:
		scores[player.name] = 0
		
	time_left = BASE_TIME_LEFT + TARGET_SCORE*len(players)
	
func crown_taken(ship):
	queen = ship
	ECM.E(queen).get('Royal').enable()
	print("CROWN TAKEN - Queen ship is now " + queen.name)
	
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
		for player in scores.keys():
			if scores[player] >= best_score:
				best_player = player
				best_score = scores[player]
		print("Time's up. Game over. " + best_player + ' wins.')
		game_over = true
		emit_signal("game_over", best_player, scores)
		
	if queen != null:
		scores[queen.name] += delta
		
		if scores[queen.name] >= TARGET_SCORE:
			print(queen.name + " wins.")
			game_over = true
			emit_signal("game_over", queen.name, scores)
