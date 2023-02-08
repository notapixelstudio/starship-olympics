extends Manager

signal show_msg

enum mode {ALL, ONLY_SELF, ONLY_OTHERS, ONLY_CPU, ONLY_PLAYERS}

func _on_ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Deadly'):
		if entity.has('Owned'):
			var owner = entity.get('Owned').get_owned_by()
			if owner != ship:
				ship.die(owner)
			else:
				var possibly_bomb = entity.get_host()
				if possibly_bomb is Bomb and (possibly_bomb.type == GameMode.BOMB_TYPE.bullet or possibly_bomb.type == GameMode.BOMB_TYPE.ball):
					pass
				elif not(other is BombCore): # bomb cores do not self kill
					ship.die(owner)
		else:
			ship.die(null)
			
func bomb_near_area_entered(other : CollisionObject2D, bomb : Bomb):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Trigger'): # Ships do not use this code anymore
		bomb.detonate()
		
		
#func _on_sth_killed(sth, killer : Ship, ship_for_good=false):
#	if sth is Ship:
#		if killer and killer is Ship:
#			if sth == killer:
#				emit_signal('show_msg', sth.species, 'SELF KILL!', sth.position)
#			elif killer.info_player.team == sth.info_player.team:
#				emit_signal('show_msg', sth.species, 'MATE KILL!', sth.position)
#			
