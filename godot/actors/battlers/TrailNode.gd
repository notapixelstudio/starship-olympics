extends Node2D

class_name Trail

var ship : Ship
var ship_e : Entity
onready var trail = $Trail
onready var collision_shape = $Area2D/CollisionShape2D


func initialize(_ship : Ship):
	ship = _ship
	ship_e = ECM.E(ship)
	ship.connect('spawned', self, '_on_sth_spawned')
	ship.connect('dead', self, '_on_sth_dead')
	
	if $Trail/Area2D:
		(ECM.E($Trail/Area2D).get('Owned') as Owned).set_owned_by(ship)

func _ready():
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

