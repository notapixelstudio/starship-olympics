extends Resource

class_name InfoPlayer

var uid : int = 0
var id : String = "P1"
var controls : String = "kb1"
var species_name : String
var kills : int = 0
var selfkills : int = 0
var cpu: bool = false
var playable : bool = true
var lives : int = 10
var deaths : int = 0
var bombs: int = 0
var collectables : int  =0
var score : float = 0.0
var session_score : int = 0
var species : SpeciesTemplate
var team: bool = false
var stats = PlayerStats

func update_death():
	deaths += 1
	return deaths

func update_collectables():
	collectables += 1
	return collectables

func set_score(new_score: float):
	score = 0.0

func get_score():
	return score 

func start():
	# This reset the scores
	score = 0.0
	lives = 10
	bombs = 0
	deaths = 0
	kills = 0
	selfkills = 0
	
func to_dict():
	return {
		"id": id,
		"name" : id,
		"controls": controls,
		"species_name" : species_name,
		"lives" : lives,
		"deaths" : deaths,
		"kills" : kills,
		"selfkills": selfkills,
		"collectables" : collectables,
		"score" : score,
		"cpu": cpu
	}

func to_stats():
	return {
		"bombs" : bombs,
		"deaths" : deaths,
		"kills" : kills,
		"selfkills": selfkills,
		"score" : score
	}