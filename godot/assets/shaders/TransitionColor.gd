@tool
extends ColorRect

@onready var anim_player = $AnimationPlayer

@export var transition = 0.0: set = set_transition
@export var smoothness = 0.0: set = set_smoothness

func set_transition(value):
	transition = value
	material.set('shader_param/cutoff', 1.0 - value)

func set_smoothness(value):
	smoothness = value
	material.set('shader_param/smooth_size', value)

func fade_to_color():
	anim_player.play("to_color")
	await anim_player.animation_finished

func fade_from_color():
	anim_player.play("to_transparent")
	await anim_player.animation_finished
