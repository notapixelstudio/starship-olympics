extends CPUBrain

var memory := {}

func _ready():
	._ready()
	
func think():
	var targets
	
	set_stance('quiet') # we can't shoot here
	log_strategy('')
	
	targets = []
	for card in get_tree().get_nodes_in_group('Card'):
		if card.is_face_down():
			targets.append(card)
	if len(targets) > 0:
		go_to(compute_nearest(targets).global_position)
		log_strategy('go to card')
		return
	
func _on_NavigationAgent2D_target_reached():
	# if we arrived on a card, attempt to select it
	request_fire()

func remember(card):
	var content = card.get_content()
	if not memory.has(content):
		memory[content] = []
	memory[content].append(card)
