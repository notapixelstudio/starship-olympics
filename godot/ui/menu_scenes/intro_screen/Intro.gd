extends Control

onready var disclaimer = $Disclaimer
onready var anim = $AnimationPlayer

onready var line1 = $Line1
onready var line2 = $Line2
onready var line3 = $Line3


export var main_screen : PackedScene

func _ready():
	
	line1.bbcode_text = tr("[center]MILLENNIA OF INTERGALACTIC WARS[/center]")
	line2.bbcode_text = tr("[center]FINALLY CAME TO AN END[/center]")
	line3.bbcode_text = tr("[center]WHEN [i]THE GAMES[/i] WERE CREATED[/center]")
	set_process_input(false)
	
	# disclaimer for analytics
	if global.first_time:
		disclaimer.start()
		yield(disclaimer, "okay")
	
	anim.play("Appear")
	
	global.install()
	global.start_execution()

func go_ahead():
	get_tree().change_scene_to(main_screen)
	
	
func _input(event):
	if not event is InputEventJoypadMotion and not event is InputEventMouse and not event is InputEventPanGesture and not event.pressed:
		go_ahead()
		set_process_input(false)
