extends Node

func _ready() -> void:
	Events.collision.connect(_on_collision)
	
func _on_collision(actor:CollisionObject2D, collider:CollisionObject2D, tag:String='') -> void:
	# actor should always be the object that detected the low-level collision
	
	# avoid checking collisions on objects that are about to be deleted
	if actor.is_queued_for_deletion() or collider.is_queued_for_deletion():
		return # collision handled
	
	if actor is Ship:
		if collider is Ship:
			_handle_ship_vs_ship(actor, collider, tag)
		else:
			_handle_ship_vs_other(actor, collider, tag)
	elif actor is Pew:
		_handle_pew_vs_other(actor, collider, tag)
	elif actor is BubbleBullet:
		_hanlde_bubble_bullet_vs_other(actor, collider, tag)
	elif actor is ShieldWall:
		_handle_shield_wall_vs_other(actor, collider, tag)

func _handle_ship_vs_ship(ship1:Ship, ship2:Ship, tag:String='') -> void:
	# avoid checking twice per collision
	if ship1.get_instance_id() < ship2.get_instance_id():
		return # collision handled
		
	ship1.swap_cargo(ship2)
	
func _handle_ship_vs_other(ship:Ship, collider:CollisionObject2D, tag:String='') -> void:
	# any touchable object by duck typing is touched
	if collider.has_method('touched_by') and tag == 'touch':
		collider.touched_by(ship)
		return # collision handled
		
	# Pews damage Ships
	if collider is Pew and tag == 'hurt':
		# no friendly fire
		if ship.get_team() == collider.get_team():
			return # collision handled
			
		ship.damage(collider)
		collider.destroy()
		return # collision handled
		
	# BubbleBullets capture Ships (or are destroyed if dashing)
	if collider is BubbleBullet and tag == 'hurt':
		if not ship.is_dashing():
			collider.capture_ship(ship)
		collider.destroy()
		return # collision handled

func _handle_pew_vs_other(pew:Pew, collider:CollisionObject2D, tag:String='') -> void:
	var is_mirror = collider is Mirror #or collider is MirrorWall
	if not is_mirror:
		pew.destroy() # Mirrors reflect Pews without destroying them
		
	if collider.has_method('hit'):
		collider.hit() # Pews hit all sorts of stuff
		
	# TBD this was needed in GoalPortal
	#if collider is Ball and pew.has_ownership_transfer() and pew.get_owner_ship() != null and is_instance_valid(pew.get_owner_ship()):
		#collider.set_player(pew.get_owner_ship().get_player())
		#collider.activate()

func _hanlde_bubble_bullet_vs_other(bubble_bullet:BubbleBullet, collider:CollisionObject2D, tag:String='') -> void:
	if collider is Treasure:
		bubble_bullet.capture_treasure(collider)
		bubble_bullet.destroy()

func _handle_shield_wall_vs_other(shield_wall:ShieldWall, collider:CollisionObject2D, tag:String='') -> void:
	if collider is Pew:
		shield_wall.down()
		collider.destroy()
