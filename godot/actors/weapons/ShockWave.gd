extends Area2D

export var angle = PI/2
export var speed = 800
export var lifetime = 0.5
var radius = 32
var t = 0

var owner_ship

func set_owner_ship(v):
	owner_ship = v
	modulate = owner_ship.species.color
	
func get_owner_ship():
	return owner_ship

func _process(delta):
	radius += speed*delta
	var base = Vector2(radius,0)
	var points = []
	for i in range(20):
		points.append(base.rotated(-angle/2+angle*(i/20.0)))
		
	var segments = []
	var i = 0
	for p in points:
		i += 1
		if i >= len(points):
			break
		segments.append(p)
		segments.append(points[i])
		
	$Line2D.points = PoolVector2Array(points)
	$CollisionShape2D.shape.segments = segments
	
	t += delta
	if t > lifetime:
		queue_free()
		
	for body in get_overlapping_bodies():
		if body != owner_ship and body.has_method('die'):
			body.die(owner_ship)
			
