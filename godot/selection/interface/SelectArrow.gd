extends Control

signal target_selected(battler)

@onready var anim_player = $Sprite2D/AnimationPlayer
@onready var tween = $Tween

@export (float) var MOVE_DURATION = 0.1

func disable():
	anim_player.stop()
	visible = false

func enable():
	anim_player.play("wiggle")
	visible = true
	
func _ready():
	enable()
