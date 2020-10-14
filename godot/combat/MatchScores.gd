extends Node
# This script handles scores and in-game stats

class_name MatchScores

var time_left:float
var match_time: float
var lasting_time: float = 0.0

var target_score: float = 100

var scores = []
var player_scores = []
var players = {} # Dictionary of InfoPlayers
var teams = {}
var sport
var draw: bool = true
var game_over:bool = false
var cumulative_points = 0
var winners = [] # Array of winning Player stats
var no_players = false

const DEADZONE = 0.1
signal game_over
signal updated

func start():
	set_process(true)

func stop():
	set_process(false)

func initialize(_players: Dictionary, game_mode: GameMode, max_score: float = 0, max_timeout: float = 0):
	scores = []
	player_scores = []
	target_score = game_mode.max_score
	sport = game_mode
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
		player_scores.append(player_score)
		players[player.id].stats = player_score
		
		var team_score
		if not(player.team in teams):
			team_score = TeamStats.new()
			scores.append(team_score)
			teams[player.team] = team_score
		else:
			team_score = teams[player.team]
			
		player_score.team_stats = team_score
		team_score.player_stats.append(player_score)
		
	time_left = game_mode.max_timeout
	if max_timeout:
		time_left = max_timeout
	
	match_time = time_left
	
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
	
	if leader.score >= target_score or time_left <= 0 or (cumulative_points>=target_score) or no_players:
		winners = []
		var draw = true
		var last_value = leader.score
		for team in scores:
			if team.score > 0 and team.score - DEADZONE <= last_value and last_value <= team.score + DEADZONE:
				draw = true
				for p in team.player_stats:
					winners.append(p)
			else:
				draw = false
		if draw:
			winners = []
		
		do_game_over()
	
	lasting_time += delta

func one_player_left(player):
	pass # this was used with old survival rules
	
func no_players_left():
	no_players = true
	
func do_game_over():
	game_over = true
	emit_signal("game_over", winners)
	
func add_score(id_player: String, amount : float, broadcasted = false):
	var player = get_player(id_player)
	player.score = player.score + amount
	teams[player.team].score += amount
	
	if cumulative_points >= 0:
		cumulative_points += amount
		
	emit_signal('updated', player, broadcasted) # author

func broadcast_score(id_player : String, amount : float):
	var player = get_player(id_player)
	for p in player_scores:
		if p.team != player.team:
			add_score(p.id, amount/len(player.team_stats.player_stats), true)


func update_stats(info_player, amount: int, stat: String):
	var id_player = info_player.id
	var stats_player = get_player(id_player)  # players[id_player]
	var stat_value = stats_player.get(stat)
	stats_player.set(stat, stat_value + amount)

func to_JSON():
	var ret = {
		
	}
	return ret


func get_player(id_player: String):
	for player in player_scores:
		if id_player == player.id:
			return player
	return 
