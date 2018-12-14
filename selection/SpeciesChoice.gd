tool
extends Control

export var species : Resource
export var controls : String

onready var ship = $Ship
onready var tween = $Tween
onready var species_name = $SpeciesName/Label
onready var character = $Character/Character
onready var controls_sprite = $Controls 
onready var player = $Player
const img_path : String = "res://assets/icon/"

	
func initialize(player_id:String):
	player.text = player_id
	controls_sprite.texture = load(img_path + controls + ".png")
	ship.texture = species.ship
	species_name.text = species.species_name.to_upper()
	character.texture = species.character
	
func previous():
	global.shake_node(species_name, tween)
	
func next():
	global.shake_node(species_name, tween)
	