extends Area2D

const ELECTRICITY_DELTA := 80.0

export var angle = PI/2
export var growth = 300
export var speed = 800
export var lifetime = 0.5

var radius = 0
var distance = 32
var t = 0

var owner_ship

func set_owner_ship(v):
	owner_ship = v
	$Line2D.modulate = owner_ship.species.color
	ECM.E(self).get('Owned').set_owned_by(owner_ship)
	
func get_owner_ship():
	return owner_ship

func _process(delta):
	radius += growth*delta
	distance += speed*delta
	var base = Vector2(radius, 0)
	$Line2D.clear_points()
	$Electricity.clear_points()
	var collider_points := []
	var resolution : int = max(10, ceil(radius*angle/40.0))
	for i in range(resolution):
		var alpha = -angle/2+angle*(i/float(resolution))
		$Line2D.add_point(base.rotated(alpha) + Vector2(distance, 0))
		$Electricity.add_point(Vector2(radius+(randf()-0.5)*ELECTRICITY_DELTA,0).rotated(alpha) + Vector2(distance, 0))
		
		# the collision shape is smaller than the arc
		if alpha > -angle*0.4 and alpha < angle*0.4:
			collider_points.append(base.rotated(alpha) + Vector2(distance, 0))
			
	var segments = []
	var i = 0
	for p in collider_points:
		i += 1
		if i >= len(collider_points):
			break
		segments.append(p)
		segments.append(collider_points[i])
		
	t += delta
	
	if not $CollisionShape2D.disabled:
		$CollisionShape2D.set_shape(ConcavePolygonShape2D.new())
		$CollisionShape2D.shape.set_segments(PoolVector2Array(segments))
		
		if t > lifetime:
			$CollisionShape2D.set_deferred('disabled', true)
			$AnimationPlayer.play("Disappear")
		
