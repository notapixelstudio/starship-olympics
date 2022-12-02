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
			if target.is_empty() and (target.is_shared() or target.is_of_player(controllee.get_player())):
				valid_targets.append(target)
		if len(valid_targets) > 0:
			var target = valid_targets[random_preference%len(valid_targets)]
			set_stance('quiet')
			go_to(target.global_position)
			log_strategy('bury skull')
			return
	
	# skulls
	targets = get_tree().get_nodes_in_group('Ball')
	if len(targets) > 0:
		# choose a preferred target skull
		var target = targets[random_preference%len(targets)]
		# target is skull
		set_stance('quiet')
		go_to(target.global_position)
		log_strategy('chase skull')
		return
	
	# enemy ships
	targets = get_tree().get_nodes_in_group('Ship')
	var valid_targets = []
	
	for target in targets:
		if target != controllee:
			valid_targets.append(target)
			
	if len(valid_targets) > 0:
		# choose a preferred target ship
		var target = valid_targets[random_preference%len(valid_targets)]
		# check weapon
		if controllee.get_bombs_enabled():
			# rockets
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
			# pew
			if global_position.distance_to(target.global_position) > 900:
				set_stance('aggressive')
				go_to(target.get_target_destination())
				log_strategy('chase ship')
			else:
				set_stance('quiet')
				var escape_vector = global_position - target.get_target_destination()
				go_to((global_position + escape_vector)*1.2) # we are too near, should go away, but also away from the center
				log_strategy('flee ship')
				start_charging_to_dash(500+randf()*800)
		return
		
	set_stance('quiet')
	go_to(Vector2.ZERO)
	log_strategy('go to center')
