extends Node

class_name InfoPlayer

var id : String = "P1"
var username: String = ""
var controls : String = "kb1"
var species  : Species

var cpu: bool = false

var playable : bool = true
var lives : int = -1
var session_score := []
var stats: PlayerStats

var team: String 

func new_match():
	self.stats = PlayerStats.new()
	
func get_username() -> String:
	return username if username != "" else 'cpu' if cpu else self.get_id()

func get_id() -> String:
	return id
	
func set_id(name: String) -> void:
	self.id = name

func add_victory(perfect = false):
	self.session_score.append({'perfect': perfect})

func to_dict():
	return {
		"id": get_id(),
		"controls": controls,
		"species_name" : species.name,
		"species": species.get_id(),
		"cpu": cpu,
		"session_score": session_score,
		"username": get_username()
	}

func to_stats():
	return stats.to_dict()

func reset():
	session_score = []

func add_score(amount):
	self.stats.score += amount

func set_species(species_: Species):
	self.species = species_

func set_species_from_id(species_id: String):
	self.set_species(global.get_species(species_id))
	
func set_score(amount):
	self.stats.score = amount

func get_score() -> float:
	return self.stats.score
	
func get_session_score_total():
	return len(session_score)

func get_species_name() -> String:
	return species.name

func get_color() -> Color:
	if is_cpu() and has_proper_team():
		return Color.SANDY_BROWN
	return species.color
	
func get_character_image():
	if is_cpu():
		return load("res://assets/sprites/species/drones/character_ok.png")
	return species.character_ok
	
func has_proper_team() -> bool:
	return self.team != self.id
	
func get_team_color() -> Color:
	return Color('#ff4a2e') if self.team == 'A' else Color('#1a59ff')

func get_ship() -> Texture2D:
	return species.get_ship()
	
func set_from_dictionary(data: Dictionary):
	self.controls = data.get("controls", self.controls)
	self.id = data.get("id", self.get_id())
	self.username = data.get("username", self.get_username())
	self.set_species_from_id(data.get("species"))
	self.session_score = data.get("session_score", [])
	self.cpu = data.get("cpu", false)
	print(data)

func is_cpu() -> bool:
	return cpu
