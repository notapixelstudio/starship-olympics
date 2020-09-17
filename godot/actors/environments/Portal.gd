extends Node2D

class_name Portal

export var linked_to_path : NodePath
export var offset : float = 200

func _on_Area2D_body_entered(body : PhysicsBody2D):
	if abs(wrapf(body.global_rotation - global_rotation, -PI, PI)) >= PI/2:
		return
		
	var entity = ECM.E(body)
	
	if not entity:
		return
		
	
	if entity.has('Teleportable'):
		print(rad2deg(wrapf(body.global_rotation - global_rotation, -PI, PI)))
		
		var teleportable = entity.get('Teleportable')
		var vector = body.position - position
		#offset = offset.rotated(-rotation)
		#offset.x = -offset.x
		#offset = offset.rotated(rotation)
		teleportable.disable()
		var linked_to = get_node(linked_to_path)
		teleportable.set_destination(linked_to.position + vector.project(Vector2(0,-1)) + offset*Vector2(-1,0).rotated(rotation+PI))
		if entity.has('Thrusters'):
			entity.get('Thrusters').disable()
			
		# temporarily disable all collisions for body
		body.get_node('CollisionShape2D').disabled = true
		
		yield(get_tree().create_timer(2), 'timeout')
		
		body.get_node('CollisionShape2D').disabled = false
		
		if teleportable:
			teleportable.enable()
		if entity.could_have('Thrusters'):
			entity.get('Thrusters').enable()
			
		
