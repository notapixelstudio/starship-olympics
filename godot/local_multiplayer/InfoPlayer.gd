extends Node

class_name InfoPlayer

var id : String = "P1"
var controls : String = "kb1"
var species_name : String
var cpu: bool = false

var playable : bool = true
var lives : int = -1
var session_score = []
var species  : Species
var stats # : PlayerStats
var team: String 
	
func to_dict():
	return {
		"id": id,
		"controls": controls,
		"species_name" : species_name,
		"cpu": cpu
	}

func to_stats():
	return stats.to_dict()

func reset():
	session_score = []
	