extends Control

signal target_selected(battler)

onready var anim_player = $Sprite/AnimationPlayer
onready var tween = $Tween

export (float) var MOVE_DURATION = 0.1

var pressed setget , is_pressed

func disable():
	anim_player.stop()
	visible = false

func enable():
	anim_player.play("wiggle")
	visible = true
	
func _ready():
	enable()

func is_pressed():
	return $Sprite.pressed
