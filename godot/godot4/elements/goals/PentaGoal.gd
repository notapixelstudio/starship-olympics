@tool
extends Area2D
class_name PentaGoal

@export var rings : int = 5 : set = set_rings
@export var ring_width : float = 50 : set = set_ring_width
@export var core_radius : float = 100 : set = set_core_radius
@export var shape_rotation_degrees : float = 0 : set = set_shape_rotation_degrees
@export var height := 64.0 : set = set_height

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

func set_height(v: float) -> void:
	height = v
	%IsoPolygon.set_height(height)
	%Rings.position.y = -height
	
var _polygon : PackedVector2Array
var _curve_global := Curve2D.new()

func set_polygon(v: PackedVector2Array) -> void:
	_polygon = v
	_curve_global.clear_points()
	for p in _polygon:
		_curve_global.add_point(to_global(p))
	%CollisionPolygon2D.set_polygon(_polygon)
	%IsoPolygon.set_polygon(_polygon)
	%FeedbackLine2D.set_points(_polygon)

func _ready() -> void:
	Events.other_collision.connect(_on_other_collision)
	
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
	
func _on_other_collision(actor, collider) -> void:
	if collider == %SolidCollider and actor is Ball:
		pass


func _on_body_entered(body: Node2D) -> void:
	if body is Ship and body.has_cargo():
		var collision = _compute_collision(body)
		if collision == null:
			return
		body.rebound_cargo(collision['position'], collision['normal'])
		%FeedbackLine2D.visible = true
		%FeedbackLine2D/AnimationPlayer.stop()
		%FeedbackLine2D/AnimationPlayer.play('feedback')

func _compute_collision(body: PhysicsBody2D) -> Variant:
	if not traits.has_trait(body, 'Tracked'):
		return null
		
	var p1 = traits.get_trait(body, 'Tracked').get_past_global_position()
	if p1 == null:
		return null
		
	var p2 = traits.get_trait(body, 'Tracked').get_past_global_position(2)
	if p2 == null:
		return null
		
	var space_state = get_world_2d().direct_space_state
	
	var a = p2 # this point is outside the area for sure
	var b = body.global_position + 10*(body.global_position - p2)
	
	var query = PhysicsRayQueryParameters2D.create(a, b, collision_layer) # set this collision layer as mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result = space_state.intersect_ray(query)
	if result == {} or result['collider'] != self:
		return null
	
	return result
	
	#var x = global_position_history[-3]
	#if _debug_point == Vector2(0,0):
		#_debug_point = to_local(a)
		#_debug_points[0] = to_local(a)
		#_debug_points[1] = to_local(b)
		##_debug_points[4] = to_local(x)
		##_debug_points[5] = to_local(a)
		#queue_redraw()
	#for i in range(len(_polygon)):
		#var c = to_global(_polygon[i])
		#var d = to_global(_polygon[(i+1) % len(_polygon)])
		#_debug_points[2] = to_local(c)
		#_debug_points[3] = to_local(d)
		#var crossing_point = Geometry2D.segment_intersects_segment(a, b, c, d)
		#if crossing_point != null:
			#print(crossing_point)
			#break
	#return null

var _debug_point := Vector2(0,0)
var _debug_points := [Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0)]
func _draw() -> void:
	draw_line(_debug_points[0],_debug_points[1],Color.RED,30.0)
	draw_line(_debug_points[2],_debug_points[3],Color.YELLOW,30.0)
	draw_line(_debug_points[4],_debug_points[5],Color.MAGENTA,30.0)
	draw_circle(_debug_point, 50.0, Color.GREEN)
