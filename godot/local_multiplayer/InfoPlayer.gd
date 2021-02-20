extends Node

class_name InfoPlayer

var id : String = "p1"
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

func random_species() -> InfoPlayer:
	"""
	Return the object itself
	"""
	var all_species = TheUnlocker.get_unlocked()
	self.species = all_species[randi()%len(all_species)]
	return self
	
func to_stats():
	return stats.to_dict()

func reset():
	session_score = []
	
