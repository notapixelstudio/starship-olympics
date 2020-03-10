tool

extends Node

class_name GShape

signal changed

export (Vector2) var center_offset = Vector2.ZERO setget set_center_offset
export var jitter : float = 0.0 setget set_jitter

func set_jitter(value):
	jitter = value
	emit_signal("changed")

func set_center_offset(value):
	center_offset = value
	emit_signal("changed")

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
	
func to_closed_PoolVector2Array_offset(vec, scale=1):
	var array = to_PoolVector2Array_offset(vec, scale)
	return array + PoolVector2Array([array[0]])
		
func _apply_offset(points):
	seed(get_instance_id()) # fixed seed for this object
	var new_points = []
	for p in points:
		new_points.append(p + center_offset + randf()*jitter*Vector2(1,0).rotated(2*PI*randf()))
	randomize()
	return PoolVector2Array(new_points)
	