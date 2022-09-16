extends RigidBody2D

class_name Bull

var entity : Entity

func _ready():
	entity = ECM.E(self)
	
var t = 0
func _process(delta):
	t += delta
	$Sprite2D.rotation -= rotation
	
	var target = entity.get('Pursuer').get_target()
	if entity.has('Pursuer') and target:
		$Sprite2D.rotation = (position-target.position).angle() - PI/2
		$Sprite2D/Eye.modulate = target.species_template.color
	else:
		$Sprite2D/Eye.modulate = Color(0,0,0,1)
		
