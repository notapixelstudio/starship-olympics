extends Node

class_name TheGame

var uuid : String
var players : Array

var deck : Deck
var all_cards : CardPool
var timestamp_local : String
var timestamp : String

class CardsSelection:
	var cards_to_choose := [] # Array of DraftCard ids
	var player_choice := {} # playerID : DraftCard Id
	
	func to_dict():
		return {
			"cards": cards_to_choose,
			"choices": player_choice
		}
		
func _init():
	uuid = UUID.v4()
	
	all_cards = CardPool.new() 
	timestamp_local = Time.get_datetime_string_from_system(false, true)
	timestamp = Time.get_datetime_string_from_system(true, true)

	
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
	
func get_last_winners() -> Array: # of InfoPlayers 
	# TODO: TBD handle more than one best player
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
		'timestamp': timestamp,
		'timestamp_local': timestamp_local,
		'players': players_dicts,
		'players_count': get_number_of_players(),
		'human_players_count': get_number_of_human_players(),
		'deck': deck_info,
		'session': session_info
	}

func set_from_dictionary(data: Dictionary):
	uuid = data.get("game_uuid", self.get_uuid())

func get_deck() -> Deck:
	return deck
	
func set_deck(v : Deck) -> void:
	# scripted first-time execeution
	# do not shuffle the deck if this is the first game of this execution
	deck = v
	if global.game_number > 1 or global.demo:
		deck.shuffle()
