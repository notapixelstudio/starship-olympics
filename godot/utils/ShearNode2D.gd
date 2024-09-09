@tool
extends Node2D


@export var shear : Vector2 = Vector2(0,0): set = set_shear

func set_shear(v: Vector2) -> void:
	shear = v
	transform.y.x = shear.x
	transform.x.y = shear.y
	
