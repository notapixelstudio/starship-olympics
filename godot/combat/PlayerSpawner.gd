extends Node2D

class_name PlayerSpawner

export (String) var controls = "kb1"
export (Resource) var species_template 
# temporary for cpu
export (bool) var cpu = false

signal entered_battlefield

var id : String
var uid : int
onready var info_player : InfoPlayer
onready var sprite = $Sprite
onready var animation = $AnimationPlayer

func _ready():
	visible = false
	
func appears():
	var device_controller_id = InputMap.get_action_list(controls+"_right")[0].device
	if "joy" in controls:
		# Vibrate if joypad
		Input.start_joy_vibration(device_controller_id, 1, 1, 0.8)
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