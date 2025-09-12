extends CPUBrain

func think():
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	if controllee.has_cargo_class(Crown):
		targets = get_tree().get_nodes_in_group('Ship')
		if len(targets) > 0:
			var escape_vector := Vector2.ZERO
			for target in targets:
				if target != controllee:
					escape_vector -= target.get_target_destination() - global_position
					
			go_to(global_position + escape_vector)
			log_strategy('escape')
			return
	
	targets = get_tree().get_nodes_in_group('Cargo')
	if len(targets) > 0:
		go_to(targets[0].global_position)
		log_strategy('chase crown')
		return
	
	targets = get_tree().get_nodes_in_group('Ship')
	if len(targets) > 0:
		for target in targets:
			if target != controllee and target.has_cargo_class(Crown):
				set_stance('aggressive')
				go_to(target.get_target_destination())
				log_strategy('chase ship')
				return
