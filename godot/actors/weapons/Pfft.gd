extends Node2D

export var species : Resource
export var timeout : float = 1.0

func _ready():
	$Particles2D.modulate = species.color
	$Particles2D.lifetime = timeout
	$Particles2D.emitting = true
	yield(get_tree().create_timer(timeout), "timeout")
	queue_free()
	
