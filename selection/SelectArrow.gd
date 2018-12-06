extends Control

signal target_selected(battler)

onready var anim_player = $Sprite/AnimationPlayer
onready var tween = $Tween

export (float) var MOVE_DURATION = 0.1

func _ready():
	anim_player.play("wiggle")