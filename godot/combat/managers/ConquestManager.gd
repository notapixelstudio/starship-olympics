extends Manager

signal conquered

func _on_ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	if ECM.E(ship).has('Conqueror') and entity.has('Conquerable'):
		var species = ECM.E(ship).get('Conqueror').get_species()
		if entity.get('Conquerable').get_species() == null:
			
			entity.get('Conquerable').set_species(species)
			emit_signal('conquered', species, entity.get_host())
			
			# AI
			entity.get('Valuable').disable()
			
	if entity.has('Fillable') and entity.could_have('Fluid'):
		entity.get_node('Fluid').enable()
		
