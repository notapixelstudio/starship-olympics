extends Control

onready var disclaimer = $CanvasLayer2/Disclaimer
onready var anim = $CanvasLayer2/AnimationPlayer

onready var line1 = $CanvasLayer2/Line1
onready var line2 = $CanvasLayer2/Line2
onready var line3 = $CanvasLayer2/Line3


export var main_screen : PackedScene

func _ready():
	#$CanvasLayer2.scale = global.get_graphics_scale()
	global.start_execution()
	
	line1.bbcode_text = tr("[center]MILLENNIA OF INTERGALACTIC WARS[/center]")
	line2.bbcode_text = tr("[center]FINALLY CAME TO AN END[/center]")
	line3.bbcode_text = tr("[center]WHEN [i]THE GAMES[/i] WERE CREATED[/center]")
	set_process_input(false)
	if global.first_time:
		disclaimer.start()
		yield(disclaimer, "okay")
	anim.play("Appear")

func go_ahead():
	get_tree().change_scene_to(main_screen)
	
	
func _input(event):
	if not event is InputEventJoypadMotion and not event is InputEventMouse and not event is InputEventPanGesture and not event.pressed:
		go_ahead()
		set_process_input(false)
		
