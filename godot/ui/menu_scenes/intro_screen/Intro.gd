extends Control

onready var disclaimer = $Disclaimer
onready var anim = $AnimationPlayer

var line1 = tr("...WHAT?! Has a [i]century[/i] passed already?")
var line2 = tr("A-hem... Welcome mortals!")
var line3 = tr("Welcome back to another edition of...")

var step = 0
var lines := [line1, line2, line3]
var voice_lines = ["res://assets/audio/voice/ref0.wav", "res://assets/audio/voice/ref1.wav", "res://assets/audio/voice/ref2.wav", "res://assets/audio/voice/ref4.wav", "res://assets/audio/voice/ref5.wav", "res://assets/audio/voice/ref6.wav"]
onready var typewriter = $Typewriter

export var main_screen : PackedScene

func _ready():
	global.start_execution()
	set_process_input(false)
	if global.first_time:
		disclaimer.start()
		yield(disclaimer, "okay")
	typewriter.type(line1)

func go_ahead():
	get_tree().change_scene_to(main_screen)
	
	
func _on_Typewriter_done():
	var text_to_find = typewriter.get_text()
	step += 1
	
	yield(get_tree().create_timer(1.5), "timeout")
	if step == 1:
		anim.play("Referee")
	elif step >= len(lines):
		anim.play("Appear")
		go_ahead() 
		set_process_input(false)
		return 
	typewriter.type(lines[step])
	$AudioStreamPlayer2D2.stream = load(voice_lines[step])
	yield(get_tree().create_timer(1), "timeout")
	$AudioStreamPlayer2D2.play()


func _on_Control_completed():
	# SKIP the intro
	go_ahead()
	set_process_input(false)
