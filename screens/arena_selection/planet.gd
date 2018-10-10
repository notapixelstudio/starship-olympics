tool
extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (Texture) var sprite setget identify_planet

var selected = false

onready var arrow = get_node("arrow_selection")

func identify_planet(new_texture):
	sprite = new_texture
	texture = new_texture
	
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
	
	
func show_planet():
	arrow.visible = true
	on_focus()

func unshow_planet():
	arrow.visible = false
	arrow.get_node("tween").stop_all()
	
func on_focus():
	var tween = arrow.get_node("tween")
	tween.interpolate_property(arrow, "position", arrow.position, arrow.position + Vector2(0, -15),
		1.5, tween.TRANS_BACK, tween.EASE_IN_OUT)
	tween.interpolate_property(arrow, "position", arrow.position + Vector2(0, -15), arrow.position,
		1.5, tween.TRANS_BACK, tween.EASE_IN_OUT, 1.5)
	tween.start()
	yield(tween, "tween_completed")