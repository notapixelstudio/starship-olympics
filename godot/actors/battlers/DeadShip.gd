extends RigidBody2D

class_name DeadShip

var ship setget set_ship

func set_ship(new_value):
	ship = new_value
	$Sprite.modulate = ship.species_template.color
	
func _enter_tree():
	linear_velocity = ship.linear_velocity
	position = ship.position
	$Death.play()

func get_killed_by(killer):
	if not killer:
		return
	print(killer.species , " with color ", killer.species_template.color)
	$Death.modulate = killer.species_template.color