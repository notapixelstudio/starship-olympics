extends Node

class_name SessionScores

# who is gonna play
var players : Dictionary setget set_players # of InfoPlayers setget

# The matches played, with scores and stats
var matches : Array # of MatchScores

var settings : Dictionary
var selected_sports : Array # of Planet


func set_players(array_players):
	players = array_players
	
	# Statistics
	for k in players:
		var info = players[k]
		global.send_stats("design", {"event_id": "selection:{key}:{id}".format({"key": info.species, "id": info.id})})
		global.send_stats("design", {"event_id": "selection:{key}:{id}".format({"key": info.controls, "id": info.id})})
	
func new_match(score):
	matches.insert(0, score)

func set_settings(_settings):
	settings = _settings