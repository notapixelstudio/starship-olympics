extends Control

class_name SpeciesContainer

export var species: Resource setget set_species #InfoPlayer 

onready var character = $Character
var is_beaten: bool = false

func get_sprite_pos():
	print_debug(character.name)
	return character.position
	
func set_species(value : InfoPlayer, beaten = true):
	species = value
	is_beaten = beaten
	refresh()
	
func _ready():
	print_debug(name, " siamo nella ready ", character.global_position)
	# refresh()
	pass


func set_score(score:int):
	print_debug(name, " siamo nella score ", character.global_position)
	yield(get_tree().create_timer(1), "timeout")
	$AnimationPlayer.play("buzzle")
	
func refresh():
	if character:
		var status_texture = (species.species_template as SpeciesTemplate).character_ok
		if is_beaten:
			status_texture = (species.species_template as SpeciesTemplate).character_beaten
		character.texture = status_texture
		
