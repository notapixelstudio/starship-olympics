extends Node2D

class_name Portal

export var linked_to_path : NodePath
export var offset : float = 250

func _on_Area2D_body_entered(body : PhysicsBody2D):
	var entity = ECM.E(body)
	
	if not entity:
		return
		
	if entity.has('Teleportable'):
		var teleportable = entity.get('Teleportable')
		var vector = body.position - position
		#offset = offset.rotated(-rotation)
		#offset.x = -offset.x
		#offset = offset.rotated(rotation)
		teleportable.disable()
		var linked_to = get_node(linked_to_path)
		teleportable.set_destination(linked_to.position  + vector.project(Vector2(0,-1).rotated(rotation+PI)) + offset*Vector2(-1,0).rotated(rotation+PI))
		#teleportable.set_destination(linked_to.position + Vector2(-100,100))
		if entity.has('Thrusters'):
			entity.get('Thrusters').disable()
			
		yield(get_tree().create_timer(0.01), 'timeout')
		
		if teleportable:
			teleportable.enable()
		if entity.could_have('Thrusters'):
			entity.get('Thrusters').enable()
			
		
