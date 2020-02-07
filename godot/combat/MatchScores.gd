extends Node
# This script handles scores and in-game stats

class_name MatchScores

var time_left:float

var target_score: float = 100

var scores = []
var players = {} # Dictionary of InfoPlayers
var draw: bool = true
var game_over:bool = false
var cumulative_points = 0
var winners = [] # Array of winning Player stats

signal game_over

func start():
	set_process(true)

func stop():
	set_process(false)

func initialize(_players: Dictionary, game_mode: GameMode, max_score: float = 0, max_timeout: float = 0):
	scores = []
	target_score = game_mode.max_score
	players = _players
	if max_score:
		target_score = max_score
	cumulative_points = -1
	
	for player_id in players:
		var player = players[player_id]
		var player_score = PlayerStats.new()
		player_score.species = player.species
		player_score.team = player.team
		player_score.id = player.id
		player_score.session_score = player.session_score
		scores.append(player_score)
		
	time_left = game_mode.max_timeout
	if max_timeout:
		time_left = max_timeout
		
	if game_mode.cumulative:
		cumulative_points=0
	
	
func sort_by_score(a, b):
	return a.score > b.score
	
func update(delta: float):
	if game_over:
		return
	
	time_left -= delta
	time_left = max(0, time_left)
	scores.sort_custom(self, "sort_by_score")
	
	var leader = scores[0]
	
	if leader.score >= target_score or time_left <= 0 or (cumulative_points>=target_score) :
		winners = []
		var draw = true
		var last_value = leader.score
		for player in scores:
			if last_value == player.score:
				draw = true
				winners.append(player)
			else:
				draw = false
		if draw:
			winners = []
		
		do_game_over()

func do_game_over():
	game_over = true
	emit_signal("game_over", winners)
		
func add_score(id_player: String, amount : float):
	var player = get_player(id_player)
	player.score = max(0, player.score + amount)
	
	if cumulative_points >= 0:
		cumulative_points += amount

func broadcast_score(team : String, amount : float):
	for team_player in scores:
		if team_player.team != team:
			add_score(team_player.id, amount)


func update_stats(info_player: InfoPlayer, amount: int, stat: String):
	var id_player = info_player.id
	var stats_player = players[id_player]
	var stat_value = stats_player.get(stat)
	stats_player.set(stat, stat_value + amount)

func to_JSON():
	var ret = {
		
	}
	return ret


func get_player(id_player: String):
	for player in scores:
		if id_player == player.id:
			return player
	return 
