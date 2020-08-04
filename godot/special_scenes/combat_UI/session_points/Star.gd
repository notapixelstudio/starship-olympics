extends Node2D

export var won : bool = false setget set_won

onready var won_anim = $Sprite/WonAnimationPlayer
onready var float_anim = $Sprite/FloatAnimationPlayer
onready var sprite = $Sprite

func floating_star(wait_time):
	yield(get_tree().create_timer(wait_time*0.2), "timeout")
	float_anim.play('float')
	
func score():
	won_anim.play("won")

func set_won(value):
	won = value
	if is_inside_tree():
		refresh()
	
func _ready():
	refresh()
	
func refresh():
	sprite.play('full' if won else 'empty')
	
