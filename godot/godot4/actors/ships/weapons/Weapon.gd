extends Node2D
class_name Weapon

var _host

func get_host() -> Node:
	return _host
	
func get_player() -> Player:
	return get_host().get_player()
	
func _enter_tree():
	_host = get_parent()
