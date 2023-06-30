extends CPUBrain

func _ready():
	._ready()
	
	Events.connect("holdable_obtained", self, '_on_holdable_obtained')
	Events.connect("holdable_lost", self, '_on_holdable_lost')

func think():
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	if controllee.get_cargo().check_class(Ball):
		targets = get_tree().get_nodes_in_group('Ship')
		if len(targets) > 0:
			var escape_vector := Vector2.ZERO
			for target in targets:
				if target != controllee:
					escape_vector -= target.get_target_destination() - global_position
					
			go_to_best_of_targets(get_tree().get_nodes_in_group('Tile'))
			log_strategy('color tile')
			return
	
	targets = get_tree().get_nodes_in_group('Ball')
	if len(targets) > 0:
		go_to(targets[0].global_position)
		log_strategy('chase ball')
		return
	
	targets = get_tree().get_nodes_in_group('Ship')
	if len(targets) > 0:
		for target in targets:
			if target != controllee and target.get_cargo().check_class(Ball):
				set_stance('aggressive')
				go_to(target.get_target_destination())
				log_strategy('chase ship')
				return

func _on_holdable_obtained(holdable, ship):
	if ship != controllee:
		return
	set_navigation_layer('holder')

func _on_holdable_lost(holdable, ship):
	if ship != controllee:
		return
	set_navigation_layer('default')

func go_to_best_of_targets(targets):
	var best = null
	var priority = null
	for target in targets:
		var strategic_value = target.get_strategic_value(controllee)
		var distance = max(global_position.distance_to(target.global_position), 0.1) # avoid divisions by zero
		if not strategic_value:
			continue
		#if strategic_value 
		var p = strategic_value / distance
		if not best or p > priority:
			best = target
			priority = p
			
	if best:
		go_to(best.global_position + controllee.linear_velocity*0.05) # try to keep moving, aim over the target
