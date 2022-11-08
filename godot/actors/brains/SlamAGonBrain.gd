extends CPUBrain

var random_preference : int

func _ready():
	random_preference = randi()
	think()
	
	Events.connect("holdable_loaded", self, '_on_holdable_loaded')
	Events.connect("holdable_swapped", self, '_on_holdable_swapped')
	Events.connect("holdable_dropped", self, '_on_holdable_dropped')

func think():
	assert(controllee.has_method('get_player'))
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	if controllee.get_cargo().check_class(Ball):
		targets = traits.get_all_with('Goal')
		var my_targets := []
		for target in targets:
			if target.get_player() == controllee.get_player():
				my_targets.append(target)
		go_to(my_targets[random_preference%len(my_targets)].global_position)
		log_strategy('attempt slam')
		return
	
	targets = get_tree().get_nodes_in_group('Ball')
	if len(targets) > 0:
		go_to(targets[0].global_position)
		log_strategy('chase ball')
		return
	
	targets = get_tree().get_nodes_in_group('Ship')
	for target in targets:
		if target != controllee and target.get_cargo().check_class(Ball):
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
