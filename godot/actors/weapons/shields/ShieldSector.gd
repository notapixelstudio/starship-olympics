extends CollisionPolygon2D

export var inner_radius := 100.0
export var outer_radius := 200.0
export var angle := PI/2
export var padding := 8.0

const COLLISION_POLYGON_PRECISION := PI/8
const DRAW_PRECISION := PI/32

func _ready():
	set_polygon(create_polygon(COLLISION_POLYGON_PRECISION))

func _draw():
	draw_colored_polygon(create_polygon(DRAW_PRECISION, padding), Color.white, PoolVector2Array(), null, null, true)

func up():
	self.call_deferred('set_disabled', false)
	$AnimationPlayer.play("reset")

func down():
	self.call_deferred('set_disabled', true)
	$AnimationPlayer.play("Disappear")
	
func is_up():
	return not disabled

func create_polygon(precision : float, padding := 0.0) -> PoolVector2Array:
	var steps := ceil(angle / precision)
	var angle_delta := angle / steps
	var points := []
	for i in range(steps+1):
		var theta := angle_delta*i
		var y := outer_radius*sin(theta)
		points.append(Vector2(outer_radius*cos(theta), max(padding, y) ))
		
	for i in range(steps+1):
		var theta := angle - angle_delta*i
		var y := inner_radius*sin(theta)
		points.append(Vector2(inner_radius*cos(theta), max(padding, y) ))
		
	return PoolVector2Array(points)
	
