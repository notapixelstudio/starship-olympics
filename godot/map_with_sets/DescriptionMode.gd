extends Control

export var gamemode : Resource setget set_gamemode

onready var animator = $AnimationPlayer

##  signal to emit when we are ready to fight
signal ready_to_fight

func _ready():
	set_process_input(false)
	refresh()
	$Continue.modulate *= Color(1,1,1,0)

func refresh():
	if not is_inside_tree():
		yield(self, 'ready')
	$Label.text = tr(gamemode.name)
	$LabelShadow.text = tr(gamemode.name)
	var label_width = $Label.get("custom_fonts/font").get_string_size(tr(gamemode.name)).x
	$LineLeft.position.x = -62 - label_width/2 - 35
	$LineRight.position.x = 998 + label_width/2 + 35
	
func set_gamemode(value: GameMode):
	gamemode = value
	refresh()

signal letsfight

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false)
		disappears()

func appears():
	visible = true
	$AudioStreamPlayer.play()
	$Description.type(tr(gamemode.description))
	yield($Description, "done")
	animator.play("describeme")
	
func disappears():
	animator.play("getout")
	$Continue.queue_free()
	yield(animator, "animation_finished")
	emit_signal("ready_to_fight")
	queue_free()

func demomode(demo = false):
	$Continue.visible = not demo


func _on_Description_done():
	set_process_input(true)
