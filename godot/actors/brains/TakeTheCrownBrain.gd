extends CPUBrain

func _ready():
	think()
	
	Events.connect("holdable_loaded", self, '_on_holdable_loaded')
	Events.connect("holdable_swapped", self, '_on_holdable_swapped')
	Events.connect("holdable_dropped", self, '_on_holdable_dropped')

func think():
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	if controllee.get_cargo().check_class(Ball):
		targets = get_tree().get_nodes_in_group('Ship')
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
	for target in targets:
		if target != controllee and target.get_cargo().check_class(Ball):
			set_stance('aggressive')
			go_to(target.get_target_destination())
			log_strategy('chase ship')
			return

func _on_holdable_loaded(holdable, ship):
	if ship != controllee:
		return
	set_navigation_layer('holder')
	
func _on_holdable_swapped(holdable1, holdable2, ship1, ship2):
	if ship1 == controllee:
		if holdable1 == null:
			set_navigation_layer('default')
		else:
			set_navigation_layer('holder')
	elif ship2 == controllee:
		if holdable2 == null:
			set_navigation_layer('default')
		else:
			set_navigation_layer('holder')

func _on_holdable_dropped(holdable, ship, cause):
	if ship != controllee:
		return
	set_navigation_layer('default')
