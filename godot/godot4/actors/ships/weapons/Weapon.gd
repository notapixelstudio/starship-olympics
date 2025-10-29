extends Node2D
class_name Weapon

@export var enabled := true

func get_host() -> Node:
	return get_parent()
	
