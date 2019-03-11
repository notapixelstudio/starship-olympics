extends RigidBody2D

var entity : Entity

func _ready():
	entity = ECM.E(self)
	
	# Crown starts ethereal then is activated to avoid dropping and recollecting too soon
	yield(get_tree().create_timer(0.4), "timeout")
	activate()
	
func activate():
	entity.get_node('Collectable').enable()
	