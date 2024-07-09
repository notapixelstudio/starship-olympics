@tool
extends Area2D
class_name PentaGoal

@export var rings : int = 5 : set = set_rings
@export var ring_width : float = 50 : set = set_ring_width
@export var core_radius : float = 100 : set = set_core_radius
@export var shape_rotation_degrees : float = 0 : set = set_shape_rotation_degrees

var _current_ring : int = 0

func set_rings(v: int) -> void:
	rings = v
	_current_ring = rings - 1
	_refresh_shape()

func set_ring_width(v: float) -> void:
	ring_width = v
	_refresh_shape()

func set_core_radius(v: float) -> void:
	core_radius = v
	_refresh_shape()
	
func set_shape_rotation_degrees(v: float) -> void:
	shape_rotation_degrees = v
	%VRegularPolygon.set_rotation_degrees(shape_rotation_degrees)

var _polygon : PackedVector2Array

func set_polygon(v: PackedVector2Array) -> void:
	_polygon = v
	%CollisionPolygon2D.set_polygon(_polygon)
	%IsoPolygon.set_polygon(_polygon)

func _ready() -> void:
	_refresh_shape()
	
	for ring in %Rings.get_children():
		ring.queue_free()
		
	for i in range(rings):
		var shape = VRegularPolygon.new()
		shape.sides = 5
		shape.radius = core_radius + ring_width * i
		shape.rotation_degrees = shape_rotation_degrees
		var ring = Line2D.new()
		ring.closed = true
		ring.default_color = Color(1,1,1,0.4)
		ring.width = 6
		ring.z_index = 8
		ring.z_as_relative = false
		shape.update()
		ring.points = shape.get_points()
		%Rings.add_child(ring)

func _refresh_shape() -> void:
	%VRegularPolygon.radius = core_radius + ring_width * _current_ring
