@tool
extends Area2D
class_name BlockRotationArea

@export var cw := true : set = set_cw

func set_cw(v:bool) -> void:
	cw = v
	%Arrow.flip_h = not cw

func is_cw() -> bool:
	return cw
