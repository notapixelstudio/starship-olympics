extends Manager

signal conquered
signal deconquered

func _on_ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if ECM.E(ship).has('Conqueror') and entity.has('Conquerable'):
		var species = ECM.E(ship).get('Conqueror').get_species()
		if species != entity.get('Conquerable').get_species():
			
			if entity.get('Conquerable').get_species() != null:
				emit_signal('deconquered', entity.get('Conquerable').get_species(), entity.get_host())
				
			entity.get('Conquerable').set_species(species)
			emit_signal('conquered', species, entity.get_host())
			
			# AI
			if entity.get('Conquerable').get_species().species == "drones":
				entity.get('Valuable').disable()
			else:
				entity.get('Valuable').enable()
				