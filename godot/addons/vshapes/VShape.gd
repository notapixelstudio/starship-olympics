@tool
extends Node
class_name VShape

@export var hosts : Array[Node]

var points : PackedVector2Array

var _dirty := false
func taint() -> void:
	_dirty = true
	
func is_dirty() -> bool:
	return _dirty
	
func _process(delta):
	if _dirty:
		update()
		_dirty = false
		
func update():
	update_hosts()

func update_hosts() -> void:
	for host in hosts:
		if host.has_method('set_polygon'):
			host.set_polygon(points)
		elif host.has_method('set_points'):
			host.set_points(points)
		
