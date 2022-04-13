extends Node

class_name InfoPlayer

var id : String = "P1"
var controls : String = "kb1"
var species  : Species

var cpu: bool = false

var playable : bool = true
var lives : int = -1
var session_score = []
var stats: PlayerStats

var team: String 

func new_match():
	self.stats = PlayerStats.new()
	
	
func set_id(name: String) -> void:
	self.id = name

func add_victory(perfect = false):
	self.session_score.append({'perfect': perfect})

func to_dict():
	return {
		"id": id,
		"controls": controls,
		"species_name" : species.name,
		"cpu": cpu
	}

func to_stats():
	return stats.to_dict()

func reset():
	session_score = []

func add_score(amount):
	self.stats.score += amount

func get_score() -> float:
	return self.stats.score
	
func get_session_score_total():
	return len(session_score)

func get_species_name() -> String:
	return species.name

func has_proper_team() -> bool:
	return self.team != self.id
	
func get_team_color() -> Color:
	return Color('#ff4a2e') if self.team == 'A' else Color('#1a59ff')
