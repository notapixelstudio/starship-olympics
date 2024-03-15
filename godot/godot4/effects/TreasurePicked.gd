extends Node2D

@export var texture : Texture : set = set_texture

func set_texture(v: Texture) -> void:
	texture = v
	%Sprite2D.texture = v
