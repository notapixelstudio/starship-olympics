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
	var polygon = create_polygon(DRAW_PRECISION, padding)
	draw_colored_polygon(polygon, Color.white, polygon, null, null, true)

func up():
	enable_collisions()
	$AnimationPlayer.play("reset")

func down():
	# collisions will be disabled near the end of the animation
	$AnimationPlayer.stop() # this would make the sector flash again - too powerful and less intuitive
	$AnimationPlayer.play("Disappear")
	
func enable_collisions():
	self.call_deferred('set_disabled', false)
	
func disable_collisions():
	self.call_deferred('set_disabled', true)
	
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
	
