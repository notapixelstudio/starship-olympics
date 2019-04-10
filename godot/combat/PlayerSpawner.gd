extends Node2D

class_name PlayerSpawner

export (String) var controls = "kb1"
export (Resource) var species_template 
# temporary for cpu
export (bool) var cpu = false

signal entered_battlefield

var id : String
var uid : int
var info_player : InfoPlayer
onready var sprite = $Sprite
onready var animation = $AnimationPlayer

func _ready():
	visible = false
	
func appears():
	var s  = species_template as SpeciesTemplate 
	sprite.texture = s.ship
	visible = true
	animation.play("Appearing")
	yield(animation, "animation_finished")
	emit_signal("entered_battlefield")
	visible = false
	
func is_cpu()->bool:
	#return info_player.cpu
	return cpu