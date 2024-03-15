@tool
class_name Treasure
extends RigidBody2D

@export var texture : Texture : set = set_texture

func set_texture(v: Texture) -> void:
	texture = v
	%Sprite2D.texture = v

func touched_by(toucher : Ship):
	Events.sth_collected.emit(toucher, self)
	queue_free()
