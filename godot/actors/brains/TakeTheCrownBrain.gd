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
					
			go_to(global_position + escape_vector)
			log_strategy('escape')
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
