extends Node
# This script handles scores and in-game stats

class_name TheMatch

var time_left : float
var time_left_secs : int
var match_time : float
var lasting_time : float = 0.0

var target_score : float = 100

var player_scores : Array = []  # of InfoPlayers. In order to keep them ordered
var players = {} # Dictionary of InfoPlayers

var draw : bool = true
var game_over : bool = false
var cumulative_points = 0

var leaders = []
var winners = [] # Array of winning InfoPlayer
var no_players = false

const DEADZONE = 0.1
signal game_over
signal setup
signal updated
signal tick

func _init():
	global.the_match = self

func start():
	set_process(true)

func stop():
	set_process(false)

func initialize(_players: Dictionary, game_mode: GameMode, max_score: float = 0, max_timeout: float = 0):
	player_scores = []
	target_score = game_mode.max_score
	
	players = _players
	
	if max_score:
		target_score = max_score
	cumulative_points = -1
	
	for player_id in players:
		var player: InfoPlayer = players[player_id]
		player.new_match()
		player_scores.append(player)
		
		
	time_left = game_mode.max_timeout
	if max_timeout:
		time_left = max_timeout
		
	if time_left != -1:
		match_time = time_left
		time_left_secs = int(time_left)
	
	if game_mode.cumulative:
		cumulative_points=0
	
	emit_signal('setup')
	
func sort_by_score(a: InfoPlayer, b: InfoPlayer):
	return a.get_score() > b.get_score()
	
func update(delta: float):
	# Would be called by Arena
	if game_over or time_left == -1:
		return
	
	time_left -= delta
	var new_time_left_secs = int(time_left)
	if new_time_left_secs != time_left_secs:
		time_left_secs = new_time_left_secs
		emit_signal('tick', time_left)
		
	if time_left <= 0:
		emit_signal('tick', 0)
		compute_game_status()
		
	lasting_time += delta
	
func compute_game_status():
	if game_over:
		print("Don't need to calculate winners again. Winners are: ")
	player_scores.sort_custom(self, "sort_by_score")
	
	leaders = []
	var leader = player_scores[0]
	for player in player_scores:
		if player.get_score() >= leader.get_score():
			leaders.append(player)
	
	if leader.get_score() >= target_score or time_left <= 0 or (cumulative_points>=target_score) or no_players:
		winners = []
		var draw = true
		var last_value = leader.get_score()
		for info_player in player_scores:
			assert(info_player is InfoPlayer)
			var player_score = info_player.get_score()
			if (player_score > 0 and player_score - DEADZONE <= last_value and 
				last_value <= player_score + DEADZONE):
				draw = true
				winners.append(info_player)
			else:
				draw = false
		if draw:
			winners = []
		
		do_game_over()
	
func one_player_left(player):
	pass # this was used with old survival rules
	
func no_players_left():
	no_players = true
	compute_game_status()
	
func do_game_over():
	game_over = true
	emit_signal("game_over")
	
func get_score(id_player : String):
	var player = get_player(id_player)
	return player.score
	
func set_score(id_player : String, amount : float, broadcasted = false):
	var player = get_player(id_player)
	player.score = amount
	
	if cumulative_points >= 0:
		cumulative_points = amount
		
	compute_game_status()
	emit_signal('updated', player, broadcasted) # author
	
func add_score(id_player : String, amount : float, broadcasted = false):
	var player: InfoPlayer = get_player(id_player)
	player.add_score(amount)
	
	if cumulative_points >= 0:
		cumulative_points += amount
		
	compute_game_status()
	emit_signal('updated', player, broadcasted) # author

func broadcast_score(id_player : String, amount : float):
	var player = get_player(id_player)
	for p in player_scores:
		if p.team != player.team:
			add_score(p.id, amount/len(p.team_stats.player_stats), true)


func update_stats(info_player: InfoPlayer, amount: int, stat: String):
	var stat_value = info_player.stats.get(stat)
	info_player.stats.set(stat, stat_value + amount)

func to_JSON():
	var ret = {
		
	}
	return ret

	
func get_player(id_player: String) -> InfoPlayer:
	return players[id_player]

func summary()->Dictionary:
	"""
	Summary stats of a played match.
	"""
	return {
		"winners": winners
	}

func get_number_of_players():
	return len(players)
	
func get_leader_players() -> Array:
	"""
	Returns:
		Array[InfoPlayer] 
	"""
	return self.leaders
