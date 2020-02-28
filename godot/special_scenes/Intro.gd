extends Control

onready var disclaimer = $Disclaimer
onready var anim = $AnimationPlayer
onready var skip = $Skip

export var main_screen : PackedScene

func _ready():
	set_process_input(false)
	if global.first_time:
		disclaimer.start()
		yield(disclaimer, "okay")
	anim.play("Appear")

func go_ahead():
	get_tree().change_scene_to(main_screen)
	
	
func _input(event):
	if not event is InputEventMouse and not event.pressed:
		go_ahead()
		set_process_input(false)