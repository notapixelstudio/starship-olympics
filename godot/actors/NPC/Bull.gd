extends RigidBody2D

class_name Bull

var entity : Entity

func _ready():
	entity = ECM.E(self)
	
var t = 0
func _process(delta):
	t += delta
	$Sprite.rotation -= rotation
	
	var target = entity.get('Pursuer').get_target()
	if entity.has('Pursuer') and target:
		$Sprite.rotation = (position-target.position).angle() - PI/2
		$Sprite/Eye.modulate = target.species_template.color
	else:
		$Sprite/Eye.modulate = Color(0,0,0,1)
		