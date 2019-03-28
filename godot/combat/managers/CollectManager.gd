extends Manager

signal collected
func ship_near_area_entered(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if entity.has('Collectable') and ship.is_alive():
		var is_loadable = ECM.E(ship).could_have('Cargo') and not ECM.E(ship).has('Cargo')
		
		if not entity.has('Keepable') or entity.has('Keepable') and is_loadable:
			entity.get('Collectable').disable() # this makes sure we don't enter here twice
			emit_signal('collected', ship, entity.get_host())
			
		if entity.has('Keepable') and is_loadable:
			ECM.E(ship).get('Cargo').load(entity.get_host())
			
signal dropped
func drop_cargo(dropper):
	var what = ECM.E(dropper).get('Cargo').unload()
	emit_signal('dropped', dropper, what)
	
func _on_ship_killed(ship : Ship, killer : Ship):
	if ECM.E(ship).has('Cargo'):
		drop_cargo(ship)
		
func _on_cargo_repelled(repeller):
	drop_cargo(repeller)
	