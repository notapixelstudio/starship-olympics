extends Control

export var gamemode : Resource setget set_gamemode

onready var animator = $AnimationPlayer

signal ready_to_fight

func _ready():
	refresh()
	$Description2.modulate *= Color(1,1,1,0) 

func refresh():
	if $Sprite and gamemode:
		$Sprite.texture = gamemode.logo
		$Description.text = tr(gamemode.description).format({"score": str(gamemode.max_score)})
	
func set_gamemode(value: GameMode):
	gamemode = value
	refresh()

signal letsfight
var youcan: bool = false

func _input(event):
	if event.is_action_pressed("ui_accept") and youcan:
		disappears()

func appears():
	visible = true
	animator.play("getin")
	yield(animator, "animation_finished")
	$AudioStreamPlayer.play()
	yield(get_tree().create_timer(0.8), "timeout")
	animator.play("describeme")
	yield(animator, "animation_finished")
	youcan = true
	
	
func disappears():
	youcan = false
	animator.play("getout")
	$Description2.queue_free()
	yield(animator, "animation_finished")
	emit_signal("ready_to_fight")
	queue_free()

func demomode(demo = false):
	print("demo is ", str(demo))
	$Description2.visible = not demo
