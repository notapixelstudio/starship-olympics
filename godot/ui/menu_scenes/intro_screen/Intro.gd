extends Control

onready var disclaimer = $Disclaimer
onready var anim = $AnimationPlayer

var line1 = tr("...what? ...has a [i]century[/i] passed already?")
var line2 = tr("a-hem... welcome mortals!")
var line3 = tr("welcome back to another edition of...")

var lines := [line1, line2, line3]
onready var typewriter = $Typewriter

export var main_screen : PackedScene

func _ready():
	global.start_execution()
	set_process_input(false)
	if global.first_time:
		disclaimer.start()
		yield(disclaimer, "okay")
	anim.play("Appear")
	typewriter.type(line1)

func go_ahead():
	get_tree().change_scene_to(main_screen)
	
	


func _on_Typewriter_done():
	var text_to_find = typewriter.get_text()
	var i = lines.find(text_to_find)
	i+= 1
	yield(get_tree().create_timer(1.5), "timeout")
	if i == 1:
		anim.play("Referee")
	elif i == len(lines):
		go_ahead()
		set_process_input(false)
		return 
	typewriter.type(lines[i])
