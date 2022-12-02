extends CPUBrain

var random_preference : int

func _ready():
	._ready()
	random_preference = randi()

func think():
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	# if we have a skull, bury it
	if controllee.get_cargo().check_class(Ball):
		# find an empty shull hole
		targets = get_tree().get_nodes_in_group('SkullHole')
		var valid_targets = []
		for target in targets:
			if target.is_empty():
				valid_targets.append(target)
		if len(valid_targets) > 0:
			var target = valid_targets[random_preference%len(valid_targets)]
			set_stance('aggressive')
			go_to(target.global_position)
			log_strategy('bury skull')
			return
	
	targets = get_tree().get_nodes_in_group('Ship')
	var valid_targets = []
	
	for target in targets:
		if target != controllee:
			valid_targets.append(target)
			
	valid_targets.append_array(get_tree().get_nodes_in_group('Ball')) # also add skulls
	
	if len(valid_targets) > 0:
		# choose a preferred target (ship or skull)
		var target = valid_targets[random_preference%len(valid_targets)]
		if target is Ship:
			if global_position.distance_to(target.global_position) > 1200:
				set_stance('quiet')
				go_to(target.get_target_destination())
				log_strategy('chase ship')
			else:
				set_stance('aggressive')
				var escape_vector = global_position - target.get_target_destination()
				go_to(global_position + escape_vector)
				log_strategy('back attack')
				start_charging_to_dash(500+randf()*500)
		else:
			# target is skull
			set_stance('aggressive')
			go_to(target.global_position)
			log_strategy('chase skull')
	else:
		forget_current_target_location()
