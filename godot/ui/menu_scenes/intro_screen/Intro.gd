extends Control

onready var disclaimer = $Disclaimer
onready var anim = $AnimationPlayer

var line1 = tr("...what? ...has a [i]century[/i] passed already?")
var line2 = tr("a-hem... welcome mortals!")
var line3 = tr("welcome back to another edition of...")

onready var typewriter = $Typewriter

export var main_screen : PackedScene

func _ready():
	global.start_execution()
	
	set_process_input(false)
	if global.first_time:
		disclaimer.start()
		yield(disclaimer, "okay")
	anim.play("Appear")
	typewriter.text = line1

func go_ahead():
	get_tree().change_scene_to(main_screen)
	
	
func _input(event):
	if not event is InputEventJoypadMotion and not event is InputEventMouse and not event is InputEventPanGesture and not event.pressed:
		go_ahead()
		set_process_input(false)
