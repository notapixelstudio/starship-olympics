extends Node2D

class_name Trail

var ship
var ship_e : Entity


onready var trail = $Trail
onready var inner_trail = $InnerTrail
onready var collision_shape = $Trail/NearArea/CollisionShape2D
onready var near_area = $Trail/NearArea
onready var farcollision_shape = $Trail/FarArea/CollisionShape2D
onready var far_area = $Trail/FarArea

export var trail_length: int setget set_trail_length
export var trail_texture : Texture

const laser_texture = preload('res://assets/sprites/weapons/laser.png')

var trail_f : float = 0.0

var segments = []
var farsegments = []

func change_visibility(v):
	visible = v
	$Trail.visible = v
	$InnerTrail.visible = v
	
func set_trail_length(value:int):
	trail_length = value
	if trail:
		trail.trail_length = trail_length
		
	
func is_deadly():
	return not collision_shape.disabled

func initialize(_ship):
	ship = _ship
	ship_e = ECM.E(ship)
	if ECM.E(ship):
		ECM.E(near_area).get('Owned').set_owned_by(ship)
		ECM.E(far_area).get('Owned').set_owned_by(ship)
	ship.connect('spawned', self, '_on_sth_spawned')
	ship.connect('dead', self, '_on_sth_dead')
	ship.connect('thrusters_off', self, '_on_thrusters_off')
	ship.connect('thrusters_on', self, '_on_thrusters_on')
	
	self.configure()


func configure(deadly : bool = false, duration : float = 0.0):
	var c1 = GlowColor.new(ship.species.color, 1.2).color
	var c2 = GlowColor.new(ship.species.color_2, 3).color
	var cm = GlowColor.new(ship.species.color_2, 1.8).color

	if deadly:
		add_to_group("Trails")
		trail.time_alive_per_point = duration
		trail.min_dist = 20
		trail.auto_alpha_gradient = false
		collision_shape.call_deferred('set_disabled', false)
		trail.texture = laser_texture
		trail.width = 40
		c1.a = 1.0
		cm.a = 0.65
		c2.a = 0.35
		trail.gradient.colors = PoolColorArray([c2,cm,c1])
		inner_trail.modulate = Color(1,1,1,1)
	else:
		remove_from_group("Trails")
		collision_shape.call_deferred('set_disabled', true)
		trail.time_alive_per_point = 0.9
		trail.min_dist = 4
		trail.texture = trail_texture
		trail.width = 100
		c1.a = 0.5
		cm.a = 0.2
		c2.a = 0
		trail.gradient.colors = PoolColorArray([c2,cm,c1])
		inner_trail.modulate = Color(1,1,1,0.5)
	
func _ready():
	
	trail_f = trail_length
	
	collision_shape.shape = ConcavePolygonShape2D.new()
	farcollision_shape.shape = ConcavePolygonShape2D.new()
	
func _process(delta):
	update()
	
func update():
	if not ship:
		maybe_erase()
		return
		
	position = ship.position + Vector2(-32,0).rotated(ship.rotation)
	rotation = ship.rotation
	
func maybe_erase():
	if trail:
		trail.erase_trail()
	if inner_trail:
		inner_trail.erase_trail()

func _on_sth_spawned(sth : Node2D):
	return
	maybe_erase()
	update()
	
func _on_sth_dead(sth : Node2D, killer):
	if trail:
		trail.stop_adding_points = true
	if inner_trail:
		inner_trail.stop_adding_points = true
	yield(trail, "no_points")
	queue_free()
	
func _on_thrusters_on():
	maybe_erase()
	update()
	change_visibility(true)

func _on_thrusters_off():
	#maybe_erase()
	change_visibility(false)

const GRACE_POINTS = 15
const GRACE_POINTS_END = 150

func add_point_to_segment(point):
	if collision_shape.disabled:
		return
	var points = trail.points
	if len(points) == 0:
		return
	segments.append(points[len(points)-1])
	segments.append(point)
	(collision_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(segments))
	# FarArea
	if len(points) < GRACE_POINTS:
		return
	farsegments.append(points[len(points)-GRACE_POINTS])
	farsegments.append(points[len(points)-GRACE_POINTS+1])
	(farcollision_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(farsegments))

func remove_point_to_segment(point):
	if collision_shape.disabled:
		return
	var points = trail.points
	if len(points) == 0:
		return
	# Twice, because!
	segments.pop_front()
	segments.pop_front()
	farsegments.pop_front()
	farsegments.pop_front()
	(collision_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(segments))
	(farcollision_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(farsegments))




