extends RigidBody2D

class_name Paddle

export var follow_rotation : bool = true

var linked_to : Node2D = null

func _physics_process(delta):
	if linked_to:
		position = linked_to.position
		if follow_rotation:
			rotation = linked_to.rotation

func _on_DockArea_body_entered(body):
	if not linked_to and body is Ship:
		link(body)
		body.connect('dead', self, '_on_ship_dead', [], CONNECT_ONESHOT)
		
func link(to_what):
	linked_to = to_what
	mode = MODE_KINEMATIC
	
	if linked_to is Ship:
		modulate = linked_to.species.color
		linked_to.supercharge = 2200
	
func unlink():
	if linked_to is Ship:
		modulate = Color(1,1,1,1)
		linked_to.supercharge = 0
		
	if linked_to.is_connected('dead', self, '_on_ship_dead'):
		linked_to.disconnect('dead', self, '_on_ship_dead')
	linked_to = null
	mode = MODE_RIGID

func _on_ship_dead(ship, killer):
	unlink()
	
