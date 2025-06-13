extends Control

@onready var disclaimer = $Disclaimer
@onready var anim = $AnimationPlayer

@onready var line1 = $Line1
@onready var line2 = $Line2
@onready var line3 = $Line3


@export var main : PackedScene

func _ready():
	
	line1.text = tr("[center]MILLENNIA OF INTERGALACTIC WARS[/center]")
	line2.text = tr("[center]FINALLY CAME TO AN END[/center]")
	line3.text = tr("[center]WHEN [color=#ffde5e][i]THE GAMES[/i][/color] WERE CREATED[/center]")
	set_process_input(false)
	
	
	anim.play("Appear")
	

func go_ahead():
	get_tree().change_scene_to_packed(main)
	
func _input(event):
	if not event is InputEventJoypadMotion and not event is InputEventMouse and not event is InputEventPanGesture and not event.pressed:
		go_ahead()
		set_process_input(false)
