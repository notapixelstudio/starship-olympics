extends Node2D

class_name Trail

var ship
var ship_e : Entity


@onready var trail = $Trail
@onready var inner_trail = $InnerTrail
@onready var collision_shape = $Trail/NearArea/CollisionShape2D
@onready var near_area = $Trail/NearArea
@onready var farcollision_shape = $Trail/FarArea/CollisionShape2D
@onready var far_area = $Trail/FarArea

@export var trail_length: int :
	get:
		return trail_length # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_trail_length
@export var trail_texture : Texture2D

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
	ship.connect('spawned',Callable(self,'_on_sth_spawned'))
	ship.connect('dead',Callable(self,'_on_sth_dead'))
	ship.connect('thrusters_off',Callable(self,'_on_thrusters_off'))
	ship.connect('thrusters_on',Callable(self,'_on_thrusters_on'))
	
	self.configure()


func configure(deadly : bool = false, duration : float = 0.0):
	var c1 = GlowColor.new(ship.species.color, 1.2).color
	var c2 = GlowColor.new(ship.species.color_2, 3).color
	var cm = GlowColor.new(ship.species.color, 1.8).color

	if deadly:
		if not is_in_group("Trails"):
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
		trail.gradient.colors = PackedColorArray([c2,cm,c1])
		inner_trail.modulate = Color(1,1,1,1)
	else:
		if is_in_group("Trails"):
			remove_from_group("Trails")
		collision_shape.call_deferred('set_disabled', true)
		trail.time_alive_per_point = 0.9
		trail.min_dist = 4
		trail.texture = trail_texture
		trail.width = 100
		c1.a = 0.5
		cm.a = 0.2
		c2.a = 0
		trail.gradient.colors = PackedColorArray([c2,cm,c1])
		inner_trail.modulate = Color(1,1,1,0.5)
	
func _ready():
	
	trail_f = trail_length
	
func _process(delta):
	update()

func update():
	if not ship or not is_instance_valid(ship):
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
	
func _on_sth_dead(sth : Node2D, killer, ship_for_good=false):
	destroy()
	
func _on_thrusters_on():
	return
	#maybe_erase()
	#update()
	#change_visibility(true)

func _on_thrusters_off():
	destroy()
	
func destroy():
	if trail:
		trail.stop_adding_points = true
	if inner_trail:
		inner_trail.stop_adding_points = true
	await trail.no_points
	queue_free()
	#change_visibility(false)

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
	collision_shape.shape = ConcavePolygonShape2D.new()
	(collision_shape.shape as ConcavePolygonShape2D).set_segments(PackedVector2Array(segments))
	# FarArea
	if len(points) < GRACE_POINTS:
		return
	farsegments.append(points[len(points)-GRACE_POINTS])
	farsegments.append(points[len(points)-GRACE_POINTS+1])
	
	farcollision_shape.shape = ConcavePolygonShape2D.new()
	(farcollision_shape.shape as ConcavePolygonShape2D).set_segments(PackedVector2Array(farsegments))

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
	
	collision_shape.shape = ConcavePolygonShape2D.new()
	farcollision_shape.shape = ConcavePolygonShape2D.new()
	(collision_shape.shape as ConcavePolygonShape2D).set_segments(PackedVector2Array(segments))
	(farcollision_shape.shape as ConcavePolygonShape2D).set_segments(PackedVector2Array(farsegments))

func set_duration(value):
	trail.time_alive_per_point = value

func add_duration(value):
	trail.time_alive_per_point += value
	
