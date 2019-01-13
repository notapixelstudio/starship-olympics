extends Node

const TIME_LEFT:float = 90.0
var time_left:float = TIME_LEFT

const TARGET_SCORE:float = 30.0
var scores:Dictionary = {}
var queen = null

var game_over:bool = false

func initialize(players:Array):
	for player in players:
		scores[player.name] = 0
		
func crown_taken(player_id:String):
	queen = player_id
	print("CROWN TAKEN - Queen ship is now " + player_id)
	
func crown_lost():
	queen = null
	print("CROWN LOST")
	
func update(delta:float):
	if game_over:
		return
		
	time_left -= delta
	
	if time_left <= 0:
		var best_score = 0
		var best_player = null
		for player in scores.keys():
			if scores[player] >= best_score:
				best_player = player
				best_score = scores[player]
		print("Time's up. Game over. " + best_player + ' wins.')
		game_over = true
		
	if queen != null:
		scores[queen] += delta
		
		if scores[queen] >= TARGET_SCORE:
			print(queen + " wins.")
			game_over = true
