extends Node

const TIME_LEFT = 5*60 # 5 minutes
var time_left = TIME_LEFT

const TARGET_SCORE = 2*60 # 2 minutes
var scores = {}
var queen = null

var game_over = false

func init(players):
	for player in players:
		scores[player] = 0
		
func crown_taken(player_id):
	queen = player_id
	
func crown_lost():
	queen = null
	
func _process(delta):
	if game_over:
		return
		
	time_left -= delta
	
	if time_left <= 0:
		# TODO find the player with the highest score
		print("Time's up. Game over.")
		game_over = true
		
	if queen != null:
		scores[queen] += delta
		
		if scores[queen] >= TARGET_SCORE:
			print(queen + " wins.")
			game_over = true
