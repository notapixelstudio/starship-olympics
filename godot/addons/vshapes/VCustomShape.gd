@tool
extends Path2D
class_name VCustomShape

@export var hosts : Array[Node] : set = set_hosts

func set_hosts(v: Array[Node]) -> void:
	hosts = v
	update_hosts()

var points : PackedVector2Array


func _ready():
	curve = curve.duplicate() # necessary for duplicating nodes correctly
	curve.changed.connect(update)
	update()

func update() -> void:
	points = curve.tessellate()
	update_hosts()

func update_hosts() -> void:
	if len(hosts) == 0 and is_inside_tree():
		if get_parent().has_method('set_polygon'):
			get_parent().set_polygon(points)
		elif get_parent().has_method('set_points'):
			get_parent().set_points(points)
			
	for host in hosts:
		if host.has_method('set_polygon'):
			host.set_polygon(points)
		elif host.has_method('set_points'):
			host.set_points(points)
		

func get_points() -> PackedVector2Array:
	return points
	
func get_extents() -> Vector2:
	return Vector2()
	
