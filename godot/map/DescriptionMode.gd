extends Control

export var gamemode : Resource setget set_gamemode
export var n_players : int = 1
onready var animator = $AnimationPlayer
onready var container = $HBoxContainer
signal ready_to_fight

func _ready():
	refresh()
	$Description2.visible = false
	for i in range(n_players-1):
		var pointer = $HBoxContainer/P1.duplicate()
		container.add_child(pointer)
		

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
		emit_signal("letsfight")

func appears():
	visible = true
	animator.play("getin")
	yield(animator, "animation_finished")
	youcan = true
	$AudioStreamPlayer.play()
	yield(get_tree().create_timer(0.8), "timeout")
	animator.play("describeme")
	yield(self, "letsfight")
	animator.play("getout")
	$Description2.queue_free()
	yield(animator, "animation_finished")
	emit_signal("ready_to_fight")
	queue_free()
	
	
