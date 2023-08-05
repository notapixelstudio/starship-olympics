extends Node2D

@export var angle = 3*PI/2
@export var growth = 1000
@export var speed = 0
@export var lifetime = 0.2

var radius = 0
var distance = 0
var t = 0
var polar_coords := []

var dying := false

func _process(delta):
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
		
	$Line2D.clear_points()
	for polar_point in polar_coords:
		$Line2D.add_point(Vector2(polar_point.rho,0).rotated(polar_point.theta) + Vector2(polar_point.offset, 0))
		
	t += delta
	
	if not dying:
		if t > lifetime:
			dying = true
			$AnimationPlayer.play("Disappear")
		
