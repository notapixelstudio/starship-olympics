extends CPUBrain

export var extents : Rect2 = Rect2(Vector2(-3200, 200), Vector2(6400, 1400))
export var go_to_center_p := 0.1

var random_preference : int

func _ready():
	._ready()
	random_preference = randi()
	
func think():
	var targets
	
	set_stance('quiet') # we can't shoot in this minigame
	log_strategy('')
	
	if controllee.get_cargo().check_class(Alien):
		var alien = controllee.get_cargo().get_holdable()
		targets = get_tree().get_nodes_in_group('homeworld')
		var my_targets := []
		for target in targets:
			if (target as Homeworld).get_kind() == (alien as Alien).kind:
				my_targets.append(target)
		if len(targets) > 0:
			go_to(my_targets[random_preference%len(my_targets)].global_position)
			log_strategy('bring back alien')
			return
			
	targets = []
	for a in get_tree().get_nodes_in_group('Alien'):
		if extents.has_point(a.global_position): # don't consider aliens outside the battlefield
			targets.append(a)
	if len(targets) > 0:
		go_to(targets[random_preference%len(targets)].global_position)
		log_strategy('take alien')
		return
	
	if randf() < go_to_center_p:
		go_to(Vector2(0,0))
		log_strategy('go to center')
	else:
		forget_current_target_location()
