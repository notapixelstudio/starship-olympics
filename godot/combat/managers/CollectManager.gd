extends Manager
signal collected
signal stolen

func ship_near_area_entered(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity or entity == ECM.E(ship):
		return
		
	if entity.has('Collectable') and ship.is_alive():
		var is_loadable = ECM.E(ship).could_have('Cargo') and not ECM.E(ship).has('Cargo')
		
		if not entity.has('Keepable') or entity.has('Keepable') and is_loadable:
			entity.get('Collectable').disable() # this makes sure we don't enter here twice
			
			if other is Diamond and ECM.E(ship).has('CoinBag'):
				ECM.E(ship).get('CoinBag').add_coin()
				
			emit_signal('collected', ship, entity.get_host())
			
		if entity.has('Keepable') and is_loadable:
			ECM.E(ship).get('Cargo').load(entity.get_host())
	
	#if entity.has("Cargo") and ECM.E(ship).could_have("Cargo"):
	#	emit_signal("stolen", ship, entity.get_host())
		
	
func ship_ring_body_entered(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has("Cargo") and ECM.E(ship).could_have("Cargo"):
		emit_signal("stolen", ship, entity.get_host())
		
		
signal dropped
signal coins_dropped
func drop_cargo(dropper):
	var what = ECM.E(dropper).get('Cargo').unload()
	emit_signal('dropped', dropper, what)
	
func _on_ship_killed(ship : Ship, killer : Ship):
	if ECM.E(ship).has('Cargo'):
		drop_cargo(ship)
		
	if ECM.E(ship).has('CoinBag'):
		var coins_dropped = ECM.E(ship).get('CoinBag').drop_some_coins()
		#emit_signal('coins_dropped', ship, coins_dropped)
		
func _on_cargo_repelled(repeller):
	drop_cargo(repeller)
	
