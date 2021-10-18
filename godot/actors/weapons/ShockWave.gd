extends Area2D

const ELECTRICITY_DELTA := 80.0

export var angle = PI/2
export var growth = 300
export var speed = 800
export var lifetime = 0.5

var radius = 0
var distance = 32
var t = 0
var polar_coords := []

var owner_ship

func set_owner_ship(v):
	owner_ship = v
	$Line2D.modulate = owner_ship.species.color
	ECM.E(self).get('Owned').set_owned_by(owner_ship)
	
func get_owner_ship():
	return owner_ship

func _physics_process(delta):
	radius += growth*delta
	distance += speed*delta
	polar_coords = []
	var resolution : int = max(10, ceil(radius*angle/40.0))
	for i in range(resolution):
		polar_coords.append({
			'rho': radius,
			'theta': -angle/2+angle*(i/float(resolution)),
			'offset': distance
		})
		
	var cartesian_points := []
	for p in polar_coords:
		# the collision shape is smaller than the arc
		if p.theta > -angle*0.4 and p.theta < angle*0.4:
			cartesian_points.append(Vector2(p.rho, 0).rotated(p.theta) + Vector2(p.offset, 0))
	
	var segments = []
	var i = 0
	for p in cartesian_points:
		i += 1
		if i >= len(cartesian_points):
			break
			
		segments.append(p)
		segments.append(cartesian_points[i])
		
	t += delta
	
	if not $CollisionShape2D.disabled:
		$CollisionShape2D.set_shape(ConcavePolygonShape2D.new())
		$CollisionShape2D.shape.set_segments(PoolVector2Array(segments))
		
		if t > lifetime:
			$CollisionShape2D.set_deferred('disabled', true)
			$AnimationPlayer.play("Disappear")
		
func _process(delta):
	$Line2D.clear_points()
	$Electricity.clear_points()
	for polar_point in polar_coords:
		$Line2D.add_point(Vector2(polar_point.rho,0).rotated(polar_point.theta) + Vector2(polar_point.offset, 0))
		$Electricity.add_point(Vector2(polar_point.rho+(randf()-0.5)*ELECTRICITY_DELTA,0).rotated(polar_point.theta) + Vector2(polar_point.offset, 0))
