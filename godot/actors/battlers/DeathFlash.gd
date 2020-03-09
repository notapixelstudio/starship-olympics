extends Node2D

export var species : Resource

func _ready():
	$explosion_halo.self_modulate = species.color
	$explosion_halo2.self_modulate = species.color
	$explosion_halo3.self_modulate = species.color

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
	