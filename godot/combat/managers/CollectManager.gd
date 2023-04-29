extends Manager
signal collected
signal stolen

func ship_sth_entered(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if (entity.has('Collectable') or traits.has_trait(other, 'Collectable')) and ship.is_alive():
		var is_loadable = ECM.E(ship).could_have('Cargo') and not ECM.E(ship).has('Cargo')
		
		if not entity.has('Keepable') or entity.has('Keepable') and is_loadable:
			entity.get('Collectable').disable() # this makes sure we don't enter here twice
				
			if other is PowerUp:
				ship.apply_powerup(other)
				
			emit_signal('collected', ship, entity.get_host())
			Events.emit_signal("sth_collected", ship, entity.get_host())
			
			ship.emit_signal('collect', other)
			if traits.has_trait(other, 'Collectable'):
				other.collect(ship)
			
		if entity.has('Keepable') and is_loadable:
			ECM.E(ship).get('Cargo').load(entity.get_host())
	
	if entity.has("Cargo") and entity.could_have("Cargo"):
		emit_signal("stolen", ship, entity.get_host())
		
	
signal dropped
signal coins_dropped
func drop_cargo(dropper):
	var what = ECM.E(dropper).get('Cargo').unload()
	emit_signal('dropped', dropper, what)
	
func _on_ship_killed(ship : Ship, killer : Ship, for_good):
	if ECM.E(ship).has('Cargo'):
		var cargo = ECM.E(ship).get('Cargo').what
		if cargo is Crown and cargo.type == Crown.types.SOCCERBALL:
			cargo.owner_ship = null
		drop_cargo(ship)
		
func _on_cargo_repelled(repeller):
	drop_cargo(repeller)
	
