extends CPUBrain

func think():
	var targets
	
	set_stance('quiet') # we can't shoot in this minigame
	log_strategy('')
	
	targets = get_tree().get_nodes_in_group('Tile')
	var nearest = null
	var distance = null
	for target in targets:
		var strategic_value = target.get_strategic_value(controllee)
		if not strategic_value:
			continue
		var d = global_position.distance_squared_to(target.global_position) / pow(strategic_value, 3)
		if not nearest or d < distance:
			nearest = target
			distance = d
			
	if nearest:
		go_to(nearest.global_position + controllee.linear_velocity*0.1) # try to keep moving, aim over the target
		log_strategy('reach tile')
		return
	
	forget_current_target_location()
