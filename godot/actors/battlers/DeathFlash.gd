extends Node2D

@export var species : Resource
@export var timeout : float = 2.0

func _ready():
	$GPUParticles2D.modulate = species.color
	$GPUParticles2D.lifetime = timeout
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(timeout).timeout
	queue_free()
	
