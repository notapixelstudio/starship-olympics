extends CPUBrain

export var forward_weapon := false
export var back_attack_distance := 1200
export var forward_attack_distance := 800
export var back_attack_probability := 1.0

var random_preference : int

func _ready():
	._ready()
	random_preference = randi()

func think():
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	targets = get_tree().get_nodes_in_group('Ship')
	var valid_targets = []
	
	for target in targets:
		if target != controllee:
			valid_targets.append(target)
			
	if len(valid_targets) > 0:
		# choose a preferred target ship
		var target = valid_targets[random_preference%len(valid_targets)]
		if forward_weapon:
			if global_position.distance_to(target.global_position) > forward_attack_distance:
				set_stance('aggressive')
				go_to(target.get_target_destination())
				log_strategy('attack ship')
			else:
				set_stance('quiet')
				var escape_vector = global_position - target.get_target_destination()
				go_to(global_position + escape_vector)
				log_strategy('keep distance')
		else: # backwards weapon
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
	else:
		set_stance('quiet')
		go_home()
