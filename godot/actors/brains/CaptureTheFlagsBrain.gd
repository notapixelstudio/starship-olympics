extends CPUBrain

var random_preference : int

func _ready():
	._ready()
	random_preference = randi()

func think():
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	# if we have a flag, take it to the base
	if controllee.get_cargo().check_class(Ball):
		# find our base
		targets = get_tree().get_nodes_in_group('FlagPole')
		var valid_targets = []
		for target in targets:
			if not target.is_full() and target.is_of_player(controllee.get_player()):
				valid_targets.append(target)
		if len(valid_targets) > 0:
			var target = valid_targets[random_preference%len(valid_targets)]
			set_stance('quiet')
			go_to(target.global_position)
			log_strategy('plant flag')
			return
			
	# ships
	targets = []
	var ships = get_tree().get_nodes_in_group('Ship')
	for ship in ships:
		if ship != controllee and ship.get_cargo().check_class(Ball):
			targets.append(ship)
			
	if len(targets) > 0:
		# choose a preferred target
		var target = targets[random_preference%len(targets)]
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
	
	# flags
	targets = get_tree().get_nodes_in_group('Ball')
	var bases = get_tree().get_nodes_in_group('FlagPole')
	
	for base in bases:
		if not base.is_of_player(controllee.get_player()) and not base.is_empty():
			targets.append(base)
			
	if len(targets) > 0:
		# choose a preferred target
		var target = targets[random_preference%len(targets)]
		set_stance('quiet')
		go_to(target.global_position)
		log_strategy('chase flag')
		return
		
	set_stance('quiet')
	go_to(Vector2.ZERO)
	log_strategy('go to center')
