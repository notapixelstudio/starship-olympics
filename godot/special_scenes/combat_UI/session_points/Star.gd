extends Node2D

class_name StarIcon

export var won : bool = false setget set_won
export var perfect : bool = false setget set_perfect

onready var won_anim = $Wrapper/WonAnimationPlayer
onready var float_anim = $Wrapper/FloatAnimationPlayer
onready var sprite = $Wrapper/Sprite
onready var label = $Wrapper/Label

func floating_star(wait_time):
	yield(get_tree().create_timer(wait_time*0.2), "timeout")
	float_anim.play('float')
	
func score():
	won_anim.play("won")
	z_index = 100
	label.text = 'PERFECT\nSCORE!' if perfect else 'BEST\nSCORE!'

func set_won(value):
	won = value
	if is_inside_tree():
		refresh()
		
func set_perfect(value):
	perfect = value
	sprite.modulate = Color(1.3,0,1.3,1)
	if is_inside_tree():
		refresh()
	
func _ready():
	refresh()
	
func refresh():
	sprite.play('full' if won else 'empty')
	
