extends Node2D

@export var color : Color
@export var timeout : float = 1.0

func _ready():
	$GPUParticles2D.modulate = color
	$GPUParticles2D.lifetime = timeout
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(timeout).timeout
	queue_free()
	
func set_color(v: Color) -> void:
	color = v
	$GPUParticles2D.modulate = color
