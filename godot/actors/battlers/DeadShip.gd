extends RigidBody2D

class_name DeadShip

var ship setget set_ship

func set_ship(new_value):
	ship = new_value
	$Sprite.modulate = ship.species_template.color
	$Sprite.modulate = $Sprite.modulate.darkened(0.5)
	$Sprite.modulate.a = 0.75
	$Sprite.texture = ship.species_template.ship
	
	
func _enter_tree():
	linear_velocity = ship.linear_velocity
	position = ship.position
	rotation = ship.rotation