extends Node2D

export var species : Resource
export var timeout : float = 2.0
export var big : = true

func _ready():
	$Particles2D.modulate = species.color
	$Particles2D.lifetime = timeout
	$Particles2D.emitting = true
	if big:
		SoundEffects.play($RandomAudioStreamPlayer2D)
		$AnimationPlayer.play("Blink")
	else:
		$Particles2D.amount = 15
		$Particles2D.process_material.scale = 1
		#$Particles2D.process_material.initial_velocity = 350
	yield(get_tree().create_timer(timeout), "timeout")
	queue_free()
	
