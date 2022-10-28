extends Node

class_name TheSession

var uuid : String
var game_id: String
var hand : Array # Array of DraftCard TODO: should be in Deck

var playing_card : DraftCard
var leaderboards : Array = []
var timestamp_local : String
var timestamp : String
func _init():
	uuid = UUID.v4()
	if global.the_game:
		game_id=global.the_game.get_uuid()
	else:
		game_id = "local_run"
	timestamp_local = Time.get_datetime_string_from_system(true, true)
	timestamp = Time.get_datetime_string_from_system(false, true)
	snapshot_leaderboard()
	
func get_uuid() -> String:
	return uuid

# The matches played, with scores and stats
var matches : Dictionary # of TheMatchSummary (a dictionary)
var ordered_matches := []

var minigame_pools : Dictionary
var players_sequence : Array
var selected_sets_by_player : Dictionary
var last_minigame = null

var settings : Dictionary
var selected_sets : Array # of Planet
var wins = 3

# mutators
var mutators = {
	"flood": false,
	"laser": false
	}

func get_mutator(mutator: String):
	if not mutator in self.mutators:
		return false
	return self.mutators[mutator]
	
func set_mutators(array: Array):
	for mutator in array:
		self.add_mutator(mutator.name)
		
func add_mutator(mutator: String):
	if mutator in self.mutators:
		self.mutators[mutator] = true
	
func set_settings(_settings):
	settings = _settings
	
func get_settings(key = null):
	if not key:
		return settings
	else:
		return settings[key]
		
func setup_selected_sets(sets: Array):
	self.selected_sets = sets

func add_to_hand(card: DraftCard, position := 0):
	hand.insert(position, card)
	
func choose_next_card() -> DraftCard:
	playing_card = null
	var next_card: DraftCard = hand.pop_front()
	playing_card = next_card
	global.the_game.deck.put_card_into_played_pile(next_card)
	return next_card

func discard_hand():
	global.the_game.deck.append_cards(hand)
	hand = []

func add_match_dict(last_match: Dictionary):
	ordered_matches.append(last_match)

func set_hand(cards : Array) -> void:
	hand = cards

func get_last_match() -> Dictionary:
	return ordered_matches.back()
	
func get_hand() -> Array:
	return hand

func to_dict() -> Dictionary:
	var serialized_cards := []
	for card in self.get_hand():
		serialized_cards.append((card as DraftCard).get_id())
	if playing_card != null:
		serialized_cards.insert(0, playing_card.get_id())
	var session_dict =  {
		"game_id": game_id,
		'timestamp': self.timestamp,
		'timestamp_local': timestamp_local,
		"uuid": get_uuid(),
		"matches": ordered_matches,
		"hand": serialized_cards
	}
	return session_dict

func set_from_dictionary(data: Dictionary):
	pass
	
func add_match(the_match: TheMatch):
	var match_dict : Dictionary = the_match.to_dict()
	matches[the_match.get_id()] = match_dict
	add_match_dict(match_dict)
	
func update_scores(match_played: TheMatch) -> void:
	var winners = match_played.winners
	for winner in winners:
		print("%s won" % [winner.id])
		winner.add_victory(match_played.winners_did_perfect())
		print("%s added victory" % [winner.id])
	# store leaderboard status after changing it
	# snapshot_leaderboard()
	print("Saving SNAPSHOT. {lead}".format({"lead": leaderboards}))
	add_match(match_played)
	
func get_last_winners() -> Array:
	var match_dict = ordered_matches.back()
	return match_dict.get("winners", [])

func snapshot_leaderboard() -> void:
	var new_leaderboard = []
	if not global.the_game:
		print("No game is in session. Skip Leaderboard creation")
		return
	for player in global.the_game.get_players():
		new_leaderboard.append(player.to_dict())
	new_leaderboard.sort_custom(self, '_sort_by_session_score')
	leaderboards.append(new_leaderboard)

func _sort_by_session_score(a, b) -> bool:
	return a["session_score"] > b["session_score"]

func get_current_leaderboard() -> Array:
	return leaderboards.back()
	
func get_previous_leaderboard() -> Array:
	return leaderboards.front()

func is_over() -> bool:
	for player in global.the_game.get_players():
		assert(player is InfoPlayer)
		if player.get_session_score_total() >= global.win:
			return true
	return false
	
func store():
	global.write_into_file("user://sessions/{id}.json".format({"id":self.uuid}), self.to_dict())
	
