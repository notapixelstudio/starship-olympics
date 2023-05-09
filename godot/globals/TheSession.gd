extends Node

class_name TheSession

var uuid : String
var game_id: String
var hand : Array # Array of DraftCard TODO: should be in Deck

var playing_card : DraftCard
var leaderboards : Array = []
var timestamp_local : String
var timestamp : String
var recovered_from_session := false

func _init():
	Events.connect("match_ended", self, "match_ended")
	uuid = UUID.v4()
	if global.the_game:
		game_id=global.the_game.get_uuid()
	else:
		game_id = "local_run"
	timestamp_local = Time.get_datetime_string_from_system(false, true)
	timestamp = Time.get_datetime_string_from_system(true, true)
	snapshot_leaderboard()


func match_ended(match_dict: Dictionary):
	add_match_dict(match_dict)
	put_back_playing_card()
	if not global.demo:
		persistance.save_game_as_latest()
	
	
func setup_from_dictionary(data: Dictionary):
	var existing_matches = data.get("matches", [])
	for existing_match in existing_matches:
		add_match_dict(existing_match)
	if not data.empty():
		recovered_from_session = true
		
func get_uuid() -> String:
	return uuid

# The matches played, with scores and stats
var matches := [] # of TheMatchSummary (a dictionary)
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
	# global.the_game.deck.put_card_into_played_pile(next_card)
	return next_card

func discard_hand():
	global.the_game.deck.append_cards(hand)
	hand = []

func add_match_dict(last_match: Dictionary):
	var match_id = last_match["id"]
	if not match_id in ordered_matches:
		matches.append(last_match)
		ordered_matches.append(match_id)
	
func set_hand(cards : Array) -> void:
	hand = cards

func get_last_match() -> Dictionary:
	return matches.back()
	
func get_hand() -> Array:
	return hand

func to_dict() -> Dictionary:
	var serialized_cards := []
	for card in self.get_hand():
		serialized_cards.append((card as DraftCard).get_id())
	var deck = global.the_game.deck if global.the_game else null
	if deck:
		deck.get_starting_deck_id()
	var session_dict =  {
		"game_id": game_id,
		'timestamp': self.timestamp,
		'timestamp_local': timestamp_local,
		"uuid": get_uuid(),
		"matches": matches,
		"hand": serialized_cards,
		"playing_card": playing_card.get_id() if playing_card != null else null,
		"starting_deck": deck.get_starting_deck_id() if deck else null
	}
	return session_dict

func update_scores(match_played: TheMatch) -> void:
	var winners = match_played.winners
	for winner in winners:
		print("%s won" % [winner.id])
		winner.add_victory(match_played.winners_did_perfect())
		print("%s added victory" % [winner.id])
	# store leaderboard status after changing it
	snapshot_leaderboard()
	print("Saving SNAPSHOT. {lead}".format({"lead": leaderboards}))

func put_back_playing_card():
	if playing_card != null:
		global.the_game.deck.put_card_into_played_pile(playing_card)
	playing_card = null

func get_last_winners() -> Array:
	var match_dict = matches.back()
	return match_dict.get("winners", [])

func snapshot_leaderboard() -> void:
	var new_leaderboard = []
	if not global.the_game:
		print("No game is in session. Skip Leaderboard creation")
		return
	for player in global.the_game.get_players():
		new_leaderboard.append(player.to_dict())
	new_leaderboard.sort_custom(self, '_sort_by_session_score')
	leaderboards.insert(0, new_leaderboard)
	if len(leaderboards) > 1:
		leaderboards = leaderboards.slice(0, 1)
	
func _sort_by_session_score(a, b) -> bool:
	return len(a["session_score"]) >= len(b["session_score"])

func get_current_leaderboard() -> Array:
	return leaderboards.front()
	
func get_previous_leaderboard() -> Array:
	return leaderboards.back()

func is_over() -> bool:
	for player in global.the_game.get_players():
		assert(player is InfoPlayer)
		if player.get_session_score_total() >= global.win:
			return true
	return false
	
func store():
	global.write_into_file("user://sessions/{id}.json".format({"id":self.uuid}), to_json(self.to_dict()))
	
