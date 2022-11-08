extends CPUBrain

var random_preference : int

func _ready():
	random_preference = randi()
	
	# set a random time to decide the card
	$ThinkTimer.wait_time = 1 + 4*randf()
	
func think():
	var targets
	
	set_stance('quiet') # we can't shoot here
	log_strategy('')
	
	targets = get_tree().get_nodes_in_group('Card')
	if len(targets) > 0:
		go_to(targets[random_preference%len(targets)].global_position)
		log_strategy('go to card')
		return
	
func _on_NavigationAgent2D_target_reached():
	# if we arrived on a card, attempt to select it after a random time
	$ReleaseTimer.wait_time = 2*randf()
	$ReleaseTimer.start()
	
	# change the preference at the same time
	random_preference = randi()
