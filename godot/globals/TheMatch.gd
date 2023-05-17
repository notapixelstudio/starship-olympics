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
var perfect_end : bool = false
var cumulative_points = 0

var leaders = []
var winners = [] # Array of winning InfoPlayer
var no_players = false
var end_on_perfect := true

var minigame : Minigame
var draft_card: DraftCard
var game_mode : GameMode


const DEADZONE = 0.1
signal game_over
signal setup
signal updated
signal tick

var uuid: String

var timestamp_local : String
var timestamp : String
func _init():
	global.the_match = self
	uuid = UUID.v4()
	timestamp_local = Time.get_datetime_string_from_system(false, true)
	timestamp = Time.get_datetime_string_from_system(true, true)
	
func get_uuid() -> String:
	return uuid

func get_id() -> String:
	return get_uuid()
	
func start():
	set_process(true)

func stop():
	set_process(false)

func initialize(_players: Dictionary, _game_mode: GameMode, max_score: float = 0, max_timeout: float = 0):
	game_mode = _game_mode
	player_scores = []
	target_score = game_mode.max_score
	
	players = _players
	end_on_perfect = game_mode.end_on_perfect
	
	if max_score:
		target_score = max_score
	cumulative_points = -1
	
	for player_id in players:
		var player: InfoPlayer = players[player_id]
		player.new_match()
		player.add_score(game_mode.starting_score)
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
	
func compute_game_status(end_now = false):
	if game_over:
		# print("Don't need to calculate winners again. Winners are: ")
		return
	player_scores.sort_custom(self, "sort_by_score")
	
	leaders = []
	var leader = player_scores.front()
	for player in player_scores:
		if player.get_score() >= leader.get_score():
			leaders.append(player)
	
	perfect_end = end_on_perfect and (leader.get_score() >= target_score or cumulative_points >= target_score)
	
	if end_now or perfect_end or time_left <= 0 or no_players:
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
				
		# no winners if perfectionist mode is active and the end was not perfect
		if draft_card and draft_card.is_perfectionist() and not perfect_end:
			winners = []
		
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
	
func is_game_over():
	return game_over
	
func get_score(id_player : String):
	var player : InfoPlayer = get_player(id_player)
	return player.get_score()
	
func set_score(id_player : String, amount : float, broadcasted = false):
	if game_over:
		return
		
	var player = get_player(id_player)
	player.set_score(amount)
	
	if cumulative_points >= 0:
		cumulative_points = amount
		
	compute_game_status()
	emit_signal('updated', player, broadcasted) # author
	
func add_score(id_player : String, amount : float, broadcasted = false):
	self._silent_add_score(id_player, amount, broadcasted)
	compute_game_status()
	
func _silent_add_score(id_player : String, amount : float, broadcasted = false):
	if game_over:
		return
		
	var player: InfoPlayer = get_player(id_player)
	player.add_score(amount)
	
	if cumulative_points >= 0:
		cumulative_points += amount
		
	emit_signal('updated', player, broadcasted) # author
	
func broadcast_score(id_player : String, amount : float):
	if game_over:
		return
		
	var player = get_player(id_player)
	for p in player_scores:
		if p.team != player.team:
			add_score(p.id, amount/len(p.team_stats.player_stats), true)


func update_stats(info_player: InfoPlayer, amount: int, stat: String):
	var stat_value = info_player.stats.get(stat)
	info_player.stats.set(stat, stat_value + amount)

	
func get_player(id_player: String) -> InfoPlayer:
	return players[id_player]
	
func get_minigame_id() -> String:
	return minigame.get_id()
	
func get_card_id() -> String:
	return draft_card.get_id()
	
func to_dict()->Dictionary:
	"""
	Summary stats of a played match.
	"""
	var winners_info = []
	for winner in self.winners:
		winners_info.append((winner as InfoPlayer).to_dict())
	var dict = {
		"id": get_id(),
		"timestamp": timestamp,
		"timestamp_local": timestamp_local,
		"winners": winners,
		"winners_info": winners_info,
		"winners_did_perfect": winners_did_perfect()
	}
	if minigame:
		dict["minigame_id"] = minigame.get_id()
	if draft_card:
		dict["card_id"] = draft_card.get_id()
		
	return dict

func get_number_of_players():
	return len(players)
	
func get_leader_players() -> Array:
	return leaders

func get_game_mode() -> GameMode:
	return game_mode
	
func get_players_in_team(team : String) -> Array: # of InfoPlayer
	var result := []
	for player in player_scores:
		if player.team == team:
			result.append(player)
	return result
	
func add_score_to_team(team : String, amount : float):
	for player in get_players_in_team(team):
		_silent_add_score(player.id, amount)
		
	compute_game_status()

func winners_did_perfect() -> bool:
	for p in get_leader_players():
		if p.get_score() >= target_score or cumulative_points >= target_score:
			return true
	return false

func set_minigame(m: Minigame):
	minigame = m
	
func get_minigame() -> Minigame:
	return minigame
	
func set_draft_card(c: DraftCard):
	draft_card = c
	
func get_draft_card() -> DraftCard:
	return draft_card

func trigger_game_over_now():
	compute_game_status(true) # end now

func store():
	global.write_into_file("user://matches/{id}.json".format({"id":self.uuid}), to_json(self.to_dict()))
	
func get_time_left() -> float:
	return time_left
