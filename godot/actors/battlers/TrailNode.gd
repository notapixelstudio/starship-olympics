extends Node2D

class_name Trail

var ship : Ship
var ship_e : Entity

onready var trail = $Trail
onready var collision_shape = $Trail/NearArea/CollisionShape2D
onready var near_area = $Trail/NearArea
onready var farcollision_shape = $Trail/FarArea/CollisionShape2D
onready var far_area = $Trail/FarArea

export var trail_texture : Texture

func is_deadly():
	return not collision_shape.disabled

func initialize(_ship : Ship):
	ship = _ship
	ship_e = ECM.E(ship)
	ship.connect('spawned', self, '_on_sth_spawned')
	ship.connect('dead', self, '_on_sth_dead')
	
	
func configure(deadly: bool):
	if deadly:
		trail.trail_length = 200
		trail.auto_alpha_gradient = false
		collision_shape.disabled = false
		trail.texture = null
	else:
		collision_shape.disabled = true
		trail.trail_length = 25
		trail.texture = trail_texture
	
	
	
func _ready():
	collision_shape.shape = ConcavePolygonShape2D.new()
	farcollision_shape.shape = ConcavePolygonShape2D.new()
	
	(ECM.E(near_area).get('Owned') as Owned).set_owned_by(ship)
	(ECM.E(far_area).get('Owned') as Owned).set_owned_by(ship)
	
	var c = Color(ship.species_template.color_2)
	trail.modulate = c
	
func _process(delta):
	update()
	
func update():
	position = ship.position + Vector2(-32,0).rotated(ship.rotation)
	rotation = ship.rotation
	
func _on_sth_spawned(sth : Node2D):
	if trail:
		trail.erase_trail()
	update()
	
func _on_sth_dead(sth : Node2D, killer : Ship):
	pass

