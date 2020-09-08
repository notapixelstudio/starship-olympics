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

var trail_f : float = 0.0

var entity

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
	
	var c1 = GlowColor.new(ship.species.color, 1.2).color
	var c2 = GlowColor.new(ship.species.color_2, 3).color
	var cm = GlowColor.new(ship.species.color_2, 1.8).color
	c1.a = 0.7
	c2.a = 0
	cm.a = 0.5
	trail.gradient.colors = PoolColorArray([c2,cm,c1])
	#trail.modulate = c
	ship.connect('spawned', self, '_on_sth_spawned')
	ship.connect('dead', self, '_on_sth_dead')
	
	
func configure(deadly: bool):
	if deadly:
		add_to_group("Trails")
		trail.trail_length = 200
		trail.auto_alpha_gradient = false
		collision_shape.disabled = false
		trail.texture = null
	else:
		remove_from_group("Trails")
		collision_shape.disabled = true
		trail.trail_length = 25
		trail.texture = trail_texture
	
	
	
func _ready():
	
	trail_f = trail_length
	
	collision_shape.shape = ConcavePolygonShape2D.new()
	farcollision_shape.shape = ConcavePolygonShape2D.new()
	
func _process(delta):
	update()
	
func update():
	position = ship.position + Vector2(-32,0).rotated(ship.rotation)
	rotation = ship.rotation
	
func _on_sth_spawned(sth : Node2D):
	if trail:
		trail.erase_trail()
	if inner_trail:
		inner_trail.erase_trail()
	update()
	
func _on_sth_dead(sth : Node2D, killer):
	if trail:
		trail.erase_trail()
	if inner_trail:
		inner_trail.erase_trail()

func add_point_to_segment(point):
	if len(points) == 0:
		return
	segments.append(points[len(points)-1])
	segments.append(point)
	(area_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(segments))
	# FarArea
	if len(points) < GRACE_POINTS: 
		return
	farsegments.append(points[len(points)-GRACE_POINTS])
	farsegments.append(points[len(points)-GRACE_POINTS+1])
	(fararea_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(farsegments))

func remove_point_to_segment(point):
	if len(points) == 0: 
		return
	# Twice, because!
	segments.pop_front()
	segments.pop_front()
	farsegments.pop_front()
	farsegments.pop_front()
	(area_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(segments))
	(fararea_shape.shape as ConcavePolygonShape2D).set_segments(PoolVector2Array(farsegments))
	
