tool
extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (Texture) var sprite setget identify_planet

onready var arrow = get_node("arrow_selection")

func identify_planet(new_texture):
	sprite = new_texture
	texture = new_texture
	
func _ready():
	arrow.visible = false
	# on_focus()
	# Called when the node is added to the scene for the first time.
	# Initialization here

func on_focus():
	var tween = arrow.get_node("tween")
	tween.interpolate_property(arrow, "position", arrow.position, arrow.position + Vector2(0, -15),
		1.5, tween.TRANS_BACK, tween.EASE_IN_OUT)
	tween.interpolate_property(arrow, "position", arrow.position + Vector2(0, -15), arrow.position,
		1.5, tween.TRANS_BACK, tween.EASE_IN_OUT, 1.5)
	tween.start()
	yield(tween, "tween_completed")
	print("ci siamo")