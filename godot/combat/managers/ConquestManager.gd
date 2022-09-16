extends Manager

signal conquered
signal lost

func _on_ship_collided(other : CollisionObject2D, ship : Ship):
	var entity = ECM.E(other)
	
	if not entity:
		return
		
	var fill = false
	
	if ECM.E(ship).has('Conqueror') and entity.has('Conquerable'):
		var species = ECM.E(ship).get('Conqueror').get_species()
		
		#if entity.get('Conquerable').get_species() != null and entity.get('Conquerable').get_species() != species:
		#	var lost_species = entity.get('Conquerable').get_species()
			# clearing a cell is delayed
			#await get_tree().create_timer(0.5).timeout
			#emit_signal('lost', lost_species, entity.get_host())
			#entity.get('Conquerable').set_species(null)
			
		# elif
		if entity.get('Conquerable').get_species() == null:
			fill = true
			entity.get('Conquerable').set_species(species)
			emit_signal('conquered', species, entity.get_host())
			

		
	if entity.has('Fillable') and entity.could_have('Fluid'):
		entity.get_node('Fluid').set_enabled(fill)
		
