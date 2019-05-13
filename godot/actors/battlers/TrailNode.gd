extends Node2D

class_name Trail

var ship : Ship
var ship_e : Entity
onready var trail = $Trail

func initialize(_ship : Ship):
	ship = _ship
	ship_e = ECM.E(ship)
	ship.connect('spawned', self, '_on_sth_spawned')
	ship.connect('dead', self, '_on_sth_dead')

func _ready():
	var c = Color(ship.species_template.color)
	c.a = 0.4
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

