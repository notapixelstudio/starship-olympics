@tool
extends Node
class_name VParametricShape

@export var hosts : Array[Node] : set = set_hosts
@export var rotation_degrees : float = 0.0 : set = set_rotation_degrees

func set_hosts(v: Array[Node]) -> void:
	hosts = v
	taint()
	
func set_rotation_degrees(v: float) -> void:
	rotation_degrees = v
	taint()

var points : PackedVector2Array


var _dirty := true
func taint() -> void:
	_dirty = true
	
func is_dirty() -> bool:
	return _dirty
	
func _physics_process(delta):
	if _dirty:
		update()
		_dirty = false
		
func update():
	update_hosts()

func update_hosts() -> void:
	for host in hosts:
		_inject_points(host)
		
	if len(hosts) == 0:
		if not is_inside_tree():
			await tree_entered
		_inject_points(get_parent())
		
func _inject_points(node):
	if not is_inside_tree():
		return
	if node.has_method('set_polygon'):
		node.set_polygon(get_points())
	elif node.has_method('set_points'):
		node.set_points(get_points())

func get_points() -> PackedVector2Array:
	return Transform2D(deg_to_rad(rotation_degrees), Vector2(0,0)) * points
	
func get_extents() -> Vector2:
	return Vector2()
