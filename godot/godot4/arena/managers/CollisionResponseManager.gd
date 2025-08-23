extends Node

func _ready() -> void:
	Events.collision.connect(_on_collision)
	
func _on_collision(actor:CollisionObject2D, collider:CollisionObject2D, tag:String='') -> void:
	# actor should always be the object that detected the low-level collision
	# return as soon as a collision is handled
	
	# Ship
	if actor is Ship:
		# any touchable object by duck typing is touched
		if collider.has_method('touched_by') and tag == 'touch':
			collider.touched_by(actor)
			return # collision handled
		
		# Pews hurt Ships
		if collider is Pew and tag == 'hurt':
			# no friendly fire
			if actor.get_team() == collider.get_team():
				return # collision handled
				
			actor.hit(collider)
			collider.destroy()
			return # collision handled
	
	# Pews hit any sort of stuff, bounces off Mirrors
	if actor is Pew:
		var is_mirror = collider is Mirror #or collider is MirrorWall
		if not is_mirror:
			actor.destroy()
			
		if collider.has_method('hit'):
			collider.hit()
			
		# TBD this was needed in GoalPortal
		#if collider is Ball and actor.has_ownership_transfer() and actor.get_owner_ship() != null and is_instance_valid(actor.get_owner_ship()):
			#collider.set_player(actor.get_owner_ship().get_player())
			#collider.activate()
		return # collision handled
