extends Node2D

var vector := Vector2(0,0) : set = set_vector

func set_vector(v : Vector2) -> void:
	vector = v

func _draw():
	draw_line(Vector2(0,0), vector, Color.WHITE, 2)


func _process(delta):
	queue_redraw()
