extends CollisionPolygon2D

export var inner_radius := 100.0
export var outer_radius := 200.0
export var angle := PI/2
export var padding := 0.0
export (String, 'shield', 'plate', 'skin') var type ='normal'
export var fill : Color = Color(0,0,0,0)

const COLLISION_POLYGON_PRECISION := PI/8
const DRAW_PRECISION := PI/32
var draw_precision : float

func _ready():
	draw_precision = DRAW_PRECISION
	set_polygon(create_polygon(COLLISION_POLYGON_PRECISION))

func _draw():
	var polygon = create_polygon(draw_precision, padding)
	draw_colored_polygon(polygon, fill, polygon, null, null, true)
	draw_polyline(PoolVector2Array(Array(polygon) + [polygon[0]]), Color(0.6,1.0,1.4), 6.0, true)
	$Shadow.polygon = polygon
	$Shadow.fill = fill
	$Shadow.update()
	
func up(new_type):
	type = new_type
	draw_precision = DRAW_PRECISION
	match type:
		'shield':
			fill = Color('#28668bff')
		'plate':
			fill = Color(1,1,1,0.4)
			draw_precision = PI/6 # more rough appearance
		'skin':
			fill = Color(0,1,0,0.5)
	update()
	enable_collisions()
	$AnimationPlayer.play("reset")

func down():
	# collisions will be disabled near the end of the animation
	$AnimationPlayer.stop() # this would make the sector flash again
	if type == 'plate':
		$AnimationPlayer.play("IndestructibleHit")
	else:
		$AnimationPlayer.play("Disappear")
	
func enable_collisions():
	self.call_deferred('set_disabled', false)
	
func disable_collisions():
	self.call_deferred('set_disabled', true)
	if type == 'skin':
		yield(get_tree().create_timer(5), "timeout")
		if type == 'skin': # shield type could have changed (e.g., if switched off)
			up('skin')
	
func is_up():
	return not disabled
	
func is_available():
	return not self.is_up() and not type == 'skin' # skin sectors are never available
	
func switch_off():
	type = 'shield'
	disable_collisions()
	modulate = Color(1.0,1.0,1.0,0.0)

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
	
