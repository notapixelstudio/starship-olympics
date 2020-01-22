extends Node2D

export var won : bool = false setget blink

onready var won_anim = $Sprite/WonAnimationPlayer
onready var float_anim = $Sprite/FloatAnimationPlayer
onready var sprite = $Sprite

func floating_star(wait_time):
	yield(get_tree().create_timer(wait_time*0.2), "timeout")
	float_anim.play('float')
	
	
	
func score():
	won_anim.play("won")

func blink(new_value: bool):
	won = new_value
	if not is_inside_tree():
		yield(self, "ready")
	sprite.animation = get_the_right_one()

func _ready():
	sprite.play(get_the_right_one())

func _on_Sprite_animation_finished():
	sprite.stop()
	sprite.frame = 0
	yield(get_tree().create_timer(3), "timeout")
	sprite.play(get_the_right_one())
	
func get_the_right_one():
	return 'full' if won else 'empty'
	