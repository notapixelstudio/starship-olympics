extends Node2D
class_name Weapon

var _player : Player

func get_player() -> Player:
	return _player
	
func _enter_tree():
	_player = get_parent().get_player()
