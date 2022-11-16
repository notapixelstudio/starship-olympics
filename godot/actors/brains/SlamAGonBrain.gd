extends CPUBrain

var random_preference : int

func _ready():
	._ready()
	random_preference = randi()
	
	Events.connect("holdable_obtained", self, '_on_holdable_obtained')
	Events.connect("holdable_lost", self, '_on_holdable_lost')

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

func _on_holdable_obtained(holdable, ship):
	if ship != controllee:
		return
	set_navigation_layer('holder')
	random_preference = randi()

func _on_holdable_lost(holdable, ship):
	if ship != controllee:
		return
	set_navigation_layer('default')
