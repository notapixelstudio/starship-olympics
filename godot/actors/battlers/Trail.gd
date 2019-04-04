extends Node2D

class_name Trail

var ship : Ship

func initialize(_ship : Ship):
	ship = _ship
	ship.connect('spawned', self, '_on_ship_spawned')
	ship.connect('dead', self, '_on_ship_dead')
	update()
	
func _process(delta):
	update()
	
func update():
	position = ship.position
	rotation = ship.rotation
	
func _on_ship_spawned(ship : Ship):
	update()
	yield(get_tree(), 'idle_frame')
	$Particles2D.emitting = true
	
func _on_ship_dead(ship : Ship, killer : Ship):
	$Particles2D.emitting = false
	