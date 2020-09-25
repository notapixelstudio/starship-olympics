extends Manager

enum mode {ALL, ONLY_SELF, ONLY_OTHERS, ONLY_CPU, ONLY_PLAYERS}

func _on_ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Deadly'):
		if entity.has('Owned') and entity.get('Owned').get_owned_by() != ship:
			ship.die(entity.get('Owned').get_owned_by())
		else:
			var possibly_bomb = entity.get_host()
			if possibly_bomb is Bomb and possibly_bomb.type == GameMode.BOMB_TYPE.bullet:
				pass
			elif not(other is BombCore): # bomb cores do not self kill
				ship.die(null)
			
func bomb_near_area_entered(other : CollisionObject2D, bomb : Bomb):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Trigger') and bomb.entity.get('Owned').get_owned_by() != entity.get_host():
		bomb.detonate()
		
