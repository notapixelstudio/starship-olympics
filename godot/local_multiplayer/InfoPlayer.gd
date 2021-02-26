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

func random_species(excluded: Array = []) -> InfoPlayer:
	"""
	@param: excluded:Array[resource (Species)] to be excluded from the selection 
	pool
	@return the object itself
	"""
	var all_species = TheUnlocker.get_unlocked()
	var sel_species = []
	for sp in all_species:
		if not sp in excluded:
			sel_species.append(sp)
	self.species = sel_species[randi()%len(sel_species)]
	return self
	
func to_stats():
	return stats.to_dict()

func reset():
	session_score = []
	
