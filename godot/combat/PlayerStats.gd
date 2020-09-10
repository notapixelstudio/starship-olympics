extends Node
# This script handles scores and in-game stats

class_name PlayerStats

var id : String
var species: Species setget _set_species
var species_name : String
var team : String
var kills : int = 0
var selfkills : int = 0
var lives : int = 10
var deaths : int = 0
var bombs: int = 0
var collectables : int  =0
var score = 0.0
var session_score = []

func add_victory(perfect = false):
	session_score.append({'perfect': perfect})

func _set_species(value):
	species = value
	species_name = species.species_name


func to_stats():
	return {
		kills=kills,
		deaths=deaths,
		bombs=bombs,
		score=score,
		selfkills=selfkills
	}
