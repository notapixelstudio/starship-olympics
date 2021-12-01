extends Control

export var gamemode : Resource setget set_gamemode

onready var animator = $AnimationPlayer

onready var rule1 = $Rule1
onready var rule2 = $Rule2

##  signal to emit when we are ready to fight
signal ready_to_fight

func _ready():
	refresh()
	$Continue.modulate *= Color(1,1,1,0)

func refresh():
	if not is_inside_tree():
		yield(self, 'ready')
		
	#$Sprite.texture = gamemode.logo
	"""
	sport_name.text = tr(gamemode.description).format({
		"score": str(gamemode.max_score),
		"time": str(gamemode.max_timeout)
	})
	"""
	$Label.text = tr(gamemode.name)
	$LabelShadow.text = tr(gamemode.name)
	var label_width = $Label.get("custom_fonts/font").get_string_size(tr(gamemode.name)).x
	$LineLeft.position.x = -62 - label_width/2 - 35
	$LineRight.position.x = 998 + label_width/2 + 35
	"""
	if "shoot_bombs" in gamemode and not gamemode["shoot_bombs"]:
		$Description3.text = 'No bombs!'
	elif "starting_ammo" in gamemode and gamemode["starting_ammo"] != -1:
		$Description3.text = 'Limited ammo!'
	"""
	
func set_gamemode(value: GameMode):
	gamemode = value
	refresh()

signal letsfight

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process_input(false)
		yield(get_tree().create_timer($Timer.time_left), 'timeout')
		disappears()

func appears():
	visible = true
	$AudioStreamPlayer.play()
	yield(get_tree().create_timer(1), 'timeout')
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
