extends Node2D

@export var sprite : Sprite2D: set = set_sprite

func set_sprite(v):
	sprite = v
	
func _ready():
	await get_tree().process_frame # wait for e.g., ships to prepare
	redraw()
	
func redraw():
	if sprite:
		%Sprite2D.texture = sprite.texture
	
