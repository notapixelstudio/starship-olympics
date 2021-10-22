extends CollisionPolygon2D

export var inner_radius := 100.0
export var outer_radius := 200.0
export var angle := PI/2

const COLLISION_POLYGON_MAX_ANGLE_DELTA := PI/8

func _ready():
	var steps := ceil(angle / COLLISION_POLYGON_MAX_ANGLE_DELTA)
	var angle_delta := angle / steps
	var points := []
	for i in range(steps+1):
		var theta := angle_delta*i
		points.append(Vector2(outer_radius*cos(theta), outer_radius*sin(theta)))
		
	for i in range(steps+1):
		var theta := angle - angle_delta*i
		points.append(Vector2(inner_radius*cos(theta), inner_radius*sin(theta)))
		
	set_polygon(PoolVector2Array(points))

func _draw():
	var radius = (inner_radius + outer_radius) / 2
	var thickness = abs(outer_radius - inner_radius)
	draw_arc(Vector2(), radius, 0, angle, 100, Color.white, thickness, true)

func up():
	self.call_deferred('set_disabled', false)
	self.set_visible(true)

func down():
	self.call_deferred('set_disabled', true)
	self.set_visible(false)
