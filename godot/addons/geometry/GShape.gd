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
	return Vector2()
	
func to_PoolVector2Array_offset(vec, scale=1):
	var points = to_PoolVector2Array()
	var new_points = []
	for p in points:
		new_points.append((p + vec)*scale)
	return PoolVector2Array(new_points)
	