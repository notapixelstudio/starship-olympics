extends RigidBody2D

class_name Crown
var entity

enum types {CROWN, BALL}
export (types) var type = types.CROWN

func _ready():
	entity = ECM.E(self)
	
	if type == types.CROWN:
		$CrownSprite.visible = true
		$BallSprite.visible = false
	elif type == types.BALL:
		$CrownSprite.visible = false
		$BallSprite.visible = true
		$CollisionShape2D.shape.radius *= 1.2
		
func _integrate_forces(state):
	# force the physics engine
	var xform = state.get_transform()
	
	# teleport
	if entity and entity.could_have('Teleportable') and entity.get('Teleportable').is_teleporting():
		xform.origin = entity.get('Teleportable').get_destination()
		entity.get('Teleportable').teleport_done()
		
	state.set_transform(xform)
