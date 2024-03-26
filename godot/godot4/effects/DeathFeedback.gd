extends Node2D

@export var color : Color

func _ready():
	modulate = color
	$GPUParticles2D.emitting = true
	#SoundEffects.play($RandomAudioStreamPlayer2D)
	$AnimationPlayer.play("Blink")
	
