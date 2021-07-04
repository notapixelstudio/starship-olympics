extends Area2D

export var angle = PI/2
export var speed = 400
export var lifetime = 0.4
var radius = 32
var t = 0

func _process(delta):
	radius += speed*delta
	var base = Vector2(radius,0)
	var points = []
	for i in range(50):
		points.append(base.rotated(-angle/2+angle*(i/50.0)))
		
	$Line2D.points = PoolVector2Array(points)
	$CollisionPolygon2D.polygon = Geometry.offset_polyline_2d(PoolVector2Array(points), 10)[0]
	
	t += delta
	if t > lifetime:
		queue_free()
