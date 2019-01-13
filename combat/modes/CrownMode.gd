extends Node

const TIME_LEFT:float = 5*60.0 # 5 minutes
var time_left:float = TIME_LEFT

const TARGET_SCORE:float = 2*60.0 # 2 minutes
var scores:Dictionary = {}
var queen = null

var game_over:bool = false

func init(players:Array):
	for player in players:
		scores[player] = 0
		
func crown_taken(player_id:String):
	queen = player_id
	
func crown_lost():
	queen = null
	
func _process(delta:float):
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
