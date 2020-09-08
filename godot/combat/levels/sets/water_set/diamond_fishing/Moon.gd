extends Node2D

export var radius = 1700.0
export var phase = -PI/2
export var speed = 0.1
var t = 0.0

func _ready():
	set_process(false)
	
func _on_Arena_battle_start():
	set_process(true)
	
func _process(delta):
	t += delta
	position = Vector2(radius*cos(t*speed + phase), radius*sin(t*speed + phase))
	
