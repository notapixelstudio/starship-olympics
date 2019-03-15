tool

extends Node

class_name GShape

signal changed

func to_PoolVector2Array():
	pass
	
func to_closed_PoolVector2Array():
	var array = to_PoolVector2Array()
	return array + PoolVector2Array([array[0]])
	
func to_Shape2D():
	pass

func get_extents() -> Vector2:
	pass
