tool
extends Control

var selected = false

func _ready():
	pass
	# on_focus()
	# Called when the node is added to the scene for the first time.
	# Initialization here

func _input(event):
	if event.is_action_pressed("continue"):
		show_arenas()

func show_arenas():
	selected = true
	$GridContainer.visible = true
	$Camera2D.visible = true
	$Camera2D.current = true
	$Camera2D.position = $GridContainer.rect_position + Vector2(100, 60)
	$Camera2D.zoom = Vector2(0.3,0.3)
	
func hide_arenas():
	selected = false
	$GridContainer.visible = false
	$Camera2D.zoom = Vector2(1,1)
	$Camera2D.current = false
	$Camera2D.position = Vector2(0,0)