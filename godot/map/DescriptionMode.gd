extends Control

export var gamemode : Resource setget set_gamemode

onready var title = $Panel/Container/Title
onready var icon = $Panel/Container/Icon
onready var descr = $Panel2/VBoxContainer/Description
onready var pro = $Panel2/VBoxContainer/Pro
onready var cons = $Panel2/VBoxContainer/Cons
onready var animator = $AnimationPlayer

signal ready_to_fight

func _ready():
	visible = false
	refresh()

func refresh():
	if $Panel/Container/Icon and gamemode:
		$Panel/Container/Icon.texture = gamemode.icon
		$Panel/Container/Title.text = gamemode.name
		$Panel2/VBoxContainer/Description.text = gamemode.description
		$Panel2/VBoxContainer/Pro.text = gamemode.tagline_pro
		$Panel2/VBoxContainer/Cons.text = gamemode.tagline_cons
		$Panel2/VideoPlayer.stream = gamemode.video_example
		$Panel2/VideoPlayer.play()
	
func set_gamemode(value: GameMode):
	gamemode = value
	refresh()

signal letsfight
var youcan: bool = false

func _input(event):
	if event.is_action_pressed("ui_accept") and youcan:
		emit_signal("letsfight")
func appears():
	animator.play("getin")
	yield(animator, "animation_finished")
	youcan = true
	yield(self, "letsfight")
	animator.play("getout")
	yield(animator, "animation_finished")
	emit_signal("ready_to_fight")
	queue_free()

func _on_VideoPlayer_finished():
	$Panel2/VideoPlayer.play()
