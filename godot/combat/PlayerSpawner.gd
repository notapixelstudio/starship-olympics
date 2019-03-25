extends Node

class_name PlayerSpawner

export (String) var controls = "kb1"
export (Resource) var species_template 
# temporary for cpu
export (bool) var cpu = false

var id : String
var uid : int
var info_player : InfoPlayer
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
func _ready():
	var s  = species_template as SpeciesTemplate 
	sprite.texture = s.ship
	animation.play("Appearing")
	
func is_cpu()->bool:
	#return info_player.cpu
	return cpu