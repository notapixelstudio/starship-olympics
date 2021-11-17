extends Node

class_name TheSession
var uuid : String

func _init():
	uuid = UUID.v4()
	
func get_uuid() -> String:
	return uuid

class PlayerArena:
	## This class will store an Arena and the player who chose it
	var player_id: String
	var minigame: PackedScene

# The matches played, with scores and stats
var matches : Array # of TheMatchSummary (a dictionary)

var minigame_pools : Dictionary
var players_sequence : Array
var selected_sets_by_player : Dictionary
var last_minigame = null

var settings : Dictionary
var selected_sets : Array # of Planet
var wins = 3

## mutators
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
	
func setup_players_selection(players_selection: Dictionary) -> void:
	# var num_CPUs = 0 if len(players) > 1 else 1
	# add_cpu(num_CPUs)
	
	# global.session.setup_selected_sets(sets)
	
	players_sequence = []
	minigame_pools = {}
	selected_sets_by_player = {}
	last_minigame = null
	
	for player_id in players_selection:
		var set : Set = players_selection[player_id]
		selected_sets_by_player[player_id] = set
		players_sequence.append(player_id)
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

func add_match(last_match: Dictionary):
	matches.insert(0, last_match)
	
func get_last_match() -> Dictionary:
	if len(matches) > 0:
		return matches[0]
	else:
		return {}

func to_dict() -> Dictionary:
	"""
	"""
	return {
		"uuid": get_uuid(),
		"matches": self.matches
	}
