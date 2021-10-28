extends CollisionPolygon2D

export var inner_radius := 100.0
export var outer_radius := 200.0
export var angle := PI/2
export var padding := 8.0
export (String, 'shield', 'plate', 'skin') var type ='normal'

const COLLISION_POLYGON_PRECISION := PI/8
const DRAW_PRECISION := PI/32
var draw_precision : float

func _ready():
	draw_precision = DRAW_PRECISION
	set_polygon(create_polygon(COLLISION_POLYGON_PRECISION))

func _draw():
	var polygon = create_polygon(draw_precision, padding)
	draw_colored_polygon(polygon, Color.white, polygon, null, null, true)
	$Shadow.polygon = polygon
	$Shadow.update()
	
func up(new_type):
	type = new_type
	draw_precision = DRAW_PRECISION
	match type:
		'shield':
			self_modulate = Color('#008bff')
		'plate':
			self_modulate = Color.white
			draw_precision = PI/6 # more rough appearance
		'skin':
			self_modulate = Color.green
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
	
