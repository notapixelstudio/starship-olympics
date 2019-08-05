extends Node2D

export var color := Color(0.0, 1.0, 0.0, 0.1)
export var influence_radius := 128.0
export var gravity := 0.0

func _input(event):
	# When mouse moves, move well indictor to mouse
	if event is InputEventMouseMotion:
		position = get_global_mouse_position()
	# If clicking the right mouse button, then apply a pulse of gravity outwards
	elif event is InputEventMouseButton && event.is_pressed():
		if event.button_index == BUTTON_RIGHT:
			gravity = -1200

func _process(delta):
	# If holding left mouse button then increase weaker inner gravity
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		gravity = lerp(gravity, 256, 0.5)
	# Else gradually decrease gravity
	else:
		gravity = lerp(gravity, 0, 0.2)
#
#func _draw():
#	draw_circle(Vector2.ZERO, influence_radius, color)