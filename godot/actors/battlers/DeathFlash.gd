extends Node2D

export var species : Resource

func _ready():
	$Particles2D.modulate = species.color
	$Particles2D2.modulate = species.color
	$explosion_halo.self_modulate = species.color
	$explosion_halo2.self_modulate = species.color
	$explosion_halo3.self_modulate = species.color
	
	$Particles2D.emitting = true
	$Particles2D2.emitting = true
	$Particles2D3.emitting = true

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
	