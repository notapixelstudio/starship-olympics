extends Node2D
class_name Weapon

@export var enabled := true
@export var host : Node = null

func get_host() -> Node:
	if host != null:
		return host
	return get_parent()
	
