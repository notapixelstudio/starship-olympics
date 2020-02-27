extends Control

onready var disclaimer = $Disclaimer
onready var anim = $AnimationPlayer
onready var skip = $Skip

func _ready():
	set_process_input(false)
	if global.first_time:
		disclaimer.start()
		yield(disclaimer, "okay")
	anim.play("Appear")

func continue():
	get_tree().change_scene(global.from_scene)
	
	
func _input(event):
	if not event is InputEventMouse and not event.pressed:
		get_tree().change_scene(global.from_scene)