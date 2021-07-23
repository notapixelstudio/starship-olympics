extends Node

class_name TheSession

class PlayerArena:
	# This class will store an Arena and the player who chose it
	var player_id: String
	var minigame: PackedScene

# who is gonna play
var players : Dictionary setget set_players # of InfoPlayers

# The matches played, with scores and stats
var matches : Array # of MatchScores

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

func get_players() -> Dictionary:
	return players
	
func set_players(_players):
	for p in _players:
		assert(_players[p] is InfoPlayer)
	players = _players
	
func reset_players():
	for player in players.values():
		player.reset()
	
func add_match(score):
	matches.insert(0, score)

func set_settings(_settings):
	settings = _settings
func get_settings(key = null):
	if not key:
		return settings
	else:
		return settings[key]
		
func get_player(id_player: String):
	return null if not id_player in players else players["id_player"]

func setup_selected_sets(sets: Array):
	self.selected_sets = sets
	
func get_last_winner():
	var best_player = null
	var best_score = 0
	for player in players.values():
		var new_score = player.get_session_score_total()
		if new_score > best_score:
			best_player = player
			best_score = new_score
	return best_player

func get_number_of_players():
	return len(players)

func setup_players_selection(players_selection: Dictionary) -> void:
	var sets = players_selection.get("sets")
	var settings = players_selection.get("settings", {})
	
	var num_CPUs = 0 if len(players) > 1 else 1
	# add_cpu(num_CPUs)
	
	# global.session.setup_selected_sets(sets)
	
	players_sequence = []
	minigame_pools = {}
	selected_sets_by_player = {}
	last_minigame = null
	
	for player in players_selection:
		var set : Set = players_selection[player]
		selected_sets_by_player[player] = set
		players_sequence.append(player)
		minigame_pools[set.name] = set.get_minigames()
		assert(len(minigame_pools[set.name]) > 0)
		minigame_pools[set.name].shuffle()
	
	players_sequence.shuffle()
	
	# first_time = true
	
	# global.new_session(players)
	# next_level(global.demo)
	
	return
	
func get_next_minigame(set: Set):
	# replenish pool if empty
	if len(minigame_pools[set.name]) == 0:
		minigame_pools[set.name] = set.get_minigames()
		minigame_pools[set.name].shuffle()
		
	return minigame_pools[set.name].pop_back()

func choose_next_level(demo = false) -> Dictionary : #{String: Minigame}
	""" Choose next level rotating sets and avoiding back to back duplicates minigames. """
	var player = players_sequence.pop_back()
	players_sequence.push_front(player)
	print(selected_sets_by_player)
	var next_set = selected_sets_by_player[player]
	
	var next_minigame : Minigame = get_next_minigame(next_set)
	
	# WARNING this is not a while because it's better to repeat a level than to
	# hang the game (in case a set contains all copies of the same levels)
	if next_minigame == last_minigame: # best effort deduplication
		next_minigame = get_next_minigame(next_set)
	
	last_minigame = next_minigame
	return {"player": player, "level": next_minigame}
	
