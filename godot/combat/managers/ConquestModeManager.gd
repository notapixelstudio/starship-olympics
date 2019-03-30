extends ModeManager

signal score
func _on_ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if ECM.E(ship).has('Conqueror') and entity.has('Conquerable'):
		var species = ECM.E(ship).get('Conqueror').get_species()
		if species != entity.get('Conquerable').get_species():
			
			if entity.get('Conquerable').get_species() != null:
				emit_signal('score', entity.get('Conquerable').get_species().species_name, -8)
				
			entity.get('Conquerable').set_species(species)
			emit_signal('score', species.species_name, 8)
			