extends Area2D
class_name PentaGoal

@export var rings : int = 5
@export var ring_width : float = 100
@export var core_radius : float = 150
@export var shape_rotation_degrees : float = 0 : set = set_shape_rotation_degrees
@export var height := 64.0
@export var debug := false

var _current_ring : int = 0


func set_polygon(polygon: PackedVector2Array) -> void:
	%CollisionPolygon2D.set_polygon(polygon)
	%IsoPolygon.set_polygon(polygon)
	%FeedbackLine2D.set_points(polygon)
	
func set_shape_rotation_degrees(v: float) -> void:
	shape_rotation_degrees = v
	%VRegularPolygon.set_rotation_degrees(shape_rotation_degrees)
	_redraw_rings()

func _ready() -> void:
	_current_ring = rings
	
	%IsoPolygon.set_height(height)
	%Rings.position.y = -height
	
	_refresh_shape()
	_redraw_rings()
	
func _redraw_rings() -> void:
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
		if i >= _current_ring:
			ring.position.y = 64
			
		%Rings.add_child(ring)

func _refresh_shape() -> void:
	if _current_ring > 0:
		%VRegularPolygon.radius = core_radius + ring_width * (_current_ring-1)

func down() -> void:
	if _current_ring <= 0:
		return
	_current_ring -= 1
	_refresh_shape()
	
	if _current_ring == 0:
		%CollisionPolygon2D.set_deferred('disabled', true)
		%SolidCollisionPolygon2D.set_deferred('disabled', true)
		%IsoPolygon.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body is Ship and body.has_cargo():
		var collision = _compute_collision(body)
		if collision == null:
			return
		body.rebound_cargo(collision['position'], collision['normal'])
		%FeedbackLine2D.visible = true
		%FeedbackLine2D/AnimationPlayer.stop()
		%FeedbackLine2D/AnimationPlayer.play('feedback')
		
		down()

func _compute_collision(body: PhysicsBody2D) -> Variant:
	if not traits.has_trait(body, 'Tracked'):
		return null
		
	var p1 = traits.get_trait(body, 'Tracked').get_past_global_position()
	if p1 == null:
		return null
		
	#var p2 = traits.get_trait(body, 'Tracked').get_past_global_position(2)
	#if p2 == null:
		#return null
		
	var space_state = get_world_2d().direct_space_state
	
	#var a = p2 # this point is outside the area for sure
	#var b = body.global_position + 10*(body.global_position - p2)
	
	var a = p1
	var b = body.global_position
	var u = (b - a).normalized() # last movement vector, normalized
	
	var a2 = a - 150*u # go back a bit
	var b2 = b + 50*u # go forward a tiny bit
	
	var query = PhysicsRayQueryParameters2D.create(a2, b2, collision_layer) # set this collision layer as mask
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var collision = space_state.intersect_ray(query)
	if collision == {} or collision['collider'] != self:
		return null
	
	#var x = traits.get_trait(body, 'Tracked').get_past_global_position(3)
	#if _debug_point == Vector2(0,0):
	#_debug_point = to_local(a)
	_debug_points[0] = to_local(a)
	_debug_points[1] = to_local(b)
	_debug_points[2] = to_local(collision['position'])
	_debug_points[3] = to_local(collision['position']+collision['normal']*100)
	_debug_points[4] = to_local(a2)
	_debug_points[5] = to_local(b2)
	#for i in range(len(_polygon)):
		#var c = to_global(_polygon[i])
		#var d = to_global(_polygon[(i+1) % len(_polygon)])
		#_debug_points[2] = to_local(c)
		#_debug_points[3] = to_local(d)
		#var crossing_point = Geometry2D.segment_intersects_segment(a2, b2, c, d)
		#if crossing_point != null:
			#_debug_point = to_local(crossing_point)
			#print(crossing_point)
			#break
	queue_redraw()
	return collision

var _debug_point := Vector2(0,0)
var _debug_points := [Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0)]
func _draw() -> void:
	if not debug:
		return
	draw_line(_debug_points[0],_debug_points[1],Color.RED,30.0)
	draw_line(_debug_points[2],_debug_points[3],Color.YELLOW,30.0)
	draw_line(_debug_points[4],_debug_points[5],Color.MAGENTA,10.0)
	draw_circle(_debug_point, 20.0, Color.GREEN)
