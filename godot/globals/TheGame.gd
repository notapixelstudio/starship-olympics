extends Node

class_name TheGame

var uuid : String
var players : Array
var timestamp_str: String

var deck : Deck

func _init():
	uuid = UUID.v4()
	timestamp_str = global.datetime_to_str(OS.get_datetime(true)) # TODO Deprecated, use Time.get_datetime_dict_from_system() instead.
	#global.write_into_file("user://games/{id_game}.json".format({"id_game":uuid}), self.to_dict())
	
func get_uuid() -> String:
	return uuid

func set_players(_players : Array) -> void:
	players = _players
	
func get_players() -> Array: # of InfoPlayer
	return players
	
func get_human_players() -> Array: # of InfoPlayer
	var humans := []
	for player in players:
		if not player.cpu:
			humans.append(player)
	return humans
	
func get_player_index() -> Dictionary:
	var index := {}
	for player in players:
		index[player.get_id()] = player
	return index
	
func get_number_of_players() -> int:
	return len(players)
	
func get_number_of_human_players() -> int:
	var count := 0
	for player in players:
		if not player.cpu:
			count += 1
	return count
	
func get_last_winners() -> Array: # of InfoPlayers TBD handle more than one best player
	var best_player = null
	var best_score = 0
	for player in players:
		var new_score = player.get_session_score_total()
		if new_score > best_score:
			best_player = player
			best_score = new_score
			
	if best_score < global.win:
		return []
		
	return [best_player]
	
func reset_players():
	for player in players:
		player.reset()
		
func to_dict() -> Dictionary:
	var players_dicts := []
	for player in players:
		players_dicts.append(player.to_dict())
	var deck_info = null
	if deck != null:
		deck_info = get_deck().to_dict()
	var session_info = null
	if global.session != null:
		session_info = global.session.to_dict()
	return {
		'game_uuid': self.get_uuid(),
		'timestamp': self.timestamp_str,
		'players': players_dicts,
		'players_count': get_number_of_players(),
		'human_players_count': get_number_of_human_players(),
		'deck': deck_info,
		'session': session_info
	}

func get_deck() -> Deck:
	return deck
	
func set_deck(v : Deck) -> void:
	# scripted first-time execeution
	# do not shuffle the deck if this is the first game of this execution
	deck = v
	if global.game_number > 1 or global.demo:
		deck.shuffle()
