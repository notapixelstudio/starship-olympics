extends Node

class_name SessionScores


# who is gonna play
var players : Dictionary setget set_players # of InfoPlayers setget

# The matches played, with scores and stats
var matches : Array # of MatchScores

var settings : Dictionary
var selected_sports : Array # of Planet
var wins = 3

# mutators
var mutators = {"flood": false,
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

func set_players(array_players):
	players = array_players
	
func add_match(score):
	matches.insert(0, score)

func set_settings(_settings):
	settings = _settings

func get_player(id_player: String):
	return null if not id_player in players else players["id_player"]
