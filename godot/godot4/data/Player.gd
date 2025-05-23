extends Resource

class_name Player

@export var id : String = "P1"
@export var username : String = ""
@export var controls : String = "kb1"
@export var species : Species = preload("res://selection/characters/mantiacs_1.tres")
@export var team : String = id
@export var cpu : bool = false


func get_id() -> String:
	return id
	
func set_id(name: String) -> void:
	if team == id:
		team = name
	id = name
	
func get_username() -> String:
	return username if username != "" else 'cpu' if cpu else self.get_id()
	
func set_species(v: Species) -> void:
	species = v
	
func get_species() -> Species:
	return species

func get_color() -> Color:
	if is_cpu() and has_proper_team():
		return Color.SANDY_BROWN
	return species.color
	
func get_character_image() -> Texture:
	if is_cpu():
		return load("res://assets/sprites/species/drones/character_ok.png")
	return species.character_ok
	
func has_proper_team() -> bool:
	return team != id
	
func get_team() -> String:
	return team
	
func set_team(name:String) -> void:
	team = name
	
func get_team_color() -> Color:
	return Color('#ff4a2e') if self.team == 'A' else Color('#1a59ff')

func get_ship_image() -> Texture:
	return species.get_ship()
	
func is_cpu() -> bool:
	return cpu

func get_controls() -> String:
	return controls
	
func set_controls(v:String) -> void:
	controls = v
