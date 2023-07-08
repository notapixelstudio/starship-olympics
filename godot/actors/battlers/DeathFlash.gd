extends Node2D

@export var color : Color
@export var timeout : float = 2.0
@export var big : = true

func _ready():
	$GPUParticles2D.modulate = color
	$GPUParticles2D.lifetime = timeout
	$GPUParticles2D.emitting = true
	if big:
		SoundEffects.play($RandomAudioStreamPlayer2D)
		$AnimationPlayer.play("Blink")
	else:
		$GPUParticles2D.amount = 15
		$GPUParticles2D.process_material.scale = 1
		#$Particles2D.process_material.initial_velocity = 350
	await get_tree().create_timer(timeout).timeout
	queue_free()
	
