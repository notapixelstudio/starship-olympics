extends Node2D

export var color : Color
export var timeout : float = 1.0

func _ready():
	$Particles2D.modulate = color
	$Particles2D.lifetime = timeout
	$Particles2D.emitting = true
	yield(get_tree().create_timer(timeout), "timeout")
	queue_free()
	
func set_color(v: Color) -> void:
	color = v
	$Particles2D.modulate = color
