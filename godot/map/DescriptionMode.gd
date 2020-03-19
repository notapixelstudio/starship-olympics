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
		if "shoot_bombs" in gamemode and not gamemode["shoot_bombs"]:
			$Description3.text = 'No bombs!'
	
func set_gamemode(value: GameMode):
	gamemode = value
	refresh()

signal letsfight

func _input(event):
	if event.is_action_pressed("ui_accept") or \
		(event is InputEventScreenTouch and VirtualJoyStickInput.is_action_pressed("fire")):
		set_process_input(false)
		yield(get_tree().create_timer($Timer.time_left), 'timeout')
		disappears()

func appears():
	visible = true
	animator.play("getin")
	yield(animator, "animation_finished")
	$AudioStreamPlayer.play()
	animator.play("describeme")
	
func disappears():
	animator.play("getout")
	$Description2.queue_free()
	yield(animator, "animation_finished")
	emit_signal("ready_to_fight")
	queue_free()

func demomode(demo = false):
	$Description2.visible = not demo
