extends CPUBrain

export var back_attack_distance := 1200
export var back_attack_probability := 1.0

var random_preference : int

func _ready():
	._ready()
	random_preference = randi()
	
func think():
	var targets
	
	set_stance('aggressive') # we CAN shoot in this minigame
	log_strategy('')
	
	# avoiding dangers takes priority over the rest
	var danger_points = get_danger_points_ahead()
	if len(danger_points) > 0:
		var escape_vector = global_position - compute_average_position(danger_points)
		go_to(global_position + escape_vector)
		log_strategy('avoid danger')
		return
	
	# chasing diamonds takes priority over attacking ships
	targets = get_tree().get_nodes_in_group('Diamond')
	if len(targets) > 0:
		go_to(targets[random_preference%len(targets)].global_position)
		log_strategy('chase diamond')
		return
		
	# if we have nothing else to do, attack ships
	targets = get_tree().get_nodes_in_group('Ship')
	var valid_targets = []
	
	for target in targets:
		if target != controllee:
			valid_targets.append(target)
			
	if len(valid_targets) > 0:
		# choose a preferred target ship
		var target = valid_targets[random_preference%len(valid_targets)]
		# backwards weapon
		if $NavigationAgent2D.distance_to_target() > back_attack_distance:
			set_stance('quiet')
			go_to(target.get_target_destination())
			log_strategy('chase ship')
		else:
			set_stance('aggressive')
			var escape_vector = global_position - target.get_target_destination()
			go_to(global_position + escape_vector)
			log_strategy('back attack')
			if randf() <= back_attack_probability:
				start_charging_to_dash(escape_vector.length()*0.2+randf()*350) # try to charge more if target is far
		return
	
	set_stance('quiet')
	go_home()
	
