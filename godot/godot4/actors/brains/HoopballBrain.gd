extends CPUBrain

@export var ball_needed := true
@export var go_to_center_p := 0.1

var random_preference : int

func _ready():
	super._ready()
	random_preference = randi()
	
	Events.connect("holdable_obtained", Callable(self, '_on_holdable_obtained'))
	Events.connect("holdable_lost", Callable(self, '_on_holdable_lost'))

func think():
	assert(controllee.has_method('get_player'))
	var targets
	
	set_stance('quiet')
	log_strategy('')

	if controllee.get_cargo().check_class(Ball) or not ball_needed:
		targets = get_tree().get_nodes_in_group('gates')
		var my_targets := []
		for target in targets: # support for multiple rings
			if target.is_enabled():
				my_targets.append(target)
				break
		if len(targets) > 0:
			go_to(my_targets[random_preference%len(my_targets)].global_position)
			log_strategy('attempt crossing')
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
			
	if randf() < go_to_center_p:
		go_to(Vector2(0,0))
		log_strategy('go to center')
	else:
		forget_current_target_location()

func _on_holdable_obtained(holdable, ship):
	if ship != controllee:
		return
	random_preference = randi()

func _on_holdable_lost(holdable, ship):
	if ship != controllee:
		return
