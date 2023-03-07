extends CPUBrain

func think():
	var targets
	
	set_stance('quiet') # we can't shoot in this minigame
	log_strategy('')
	
	targets = get_tree().get_nodes_in_group('Tile')
	var best = null
	var priority = null
	for target in targets:
		var strategic_value = target.get_strategic_value(controllee)
		var distance = max(global_position.distance_to(target.global_position), 0.1) # avoid divisions by zero
		if not strategic_value:
			continue
		#if strategic_value 
		var p = pow(strategic_value, 5) / distance
		if not best or p > priority:
			best = target
			priority = p
			
	if best:
		go_to(best.global_position + controllee.linear_velocity*0.15) # try to keep moving, aim over the target
		log_strategy('reach tile')
		return
	
	forget_current_target_location()
