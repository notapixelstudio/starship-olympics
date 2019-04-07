extends RigidBody2D

class_name DeadShip

var ship setget set_ship

var entity : Entity

func _ready():
	entity = ECM.E(self)
	
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
	
func _integrate_forces(state):
	# force the physics engine
	var xform = state.get_transform()
	
	# teleport
	if entity.could_have('Teleportable') and entity.get('Teleportable').is_teleporting():
		xform.origin = entity.get('Teleportable').get_destination()
		entity.get('Teleportable').teleport_done()
		
	state.set_transform(xform)
	