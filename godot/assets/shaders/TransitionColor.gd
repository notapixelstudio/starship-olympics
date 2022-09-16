@tool
extends ColorRect

@onready var anim_player = $AnimationPlayer

@export_range(0.0, 1.0) var transition = 0.0 :
	set(value):
		transition = value
		material.set('shader_param/cutoff', 1.0 - value)
		
@export_range(0.0, 1.0) var smoothness = 0.0:
	set(value):
		smoothness = value
		material.set('shader_param/smooth_size', value)


func fade_to_color():
	anim_player.play("to_color")
	await anim_player.animation_finished

func fade_from_color():
	anim_player.play("to_transparent")
	await anim_player.animation_finished
