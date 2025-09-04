extends CPUBrain

var mines_memory := {}

func _ready():
	super._ready()
	
	Events.connect("battle_start", Callable(self, '_on_battle_start'))
	
func think():
	var targets
	
	set_stance('quiet') # we can't shoot here
	log_strategy('')
	
	targets = []
	for card in get_tree().get_nodes_in_group('Card'):
		if card.is_face_down() and not mines_memory.has(card):
			targets.append(card)
	if len(targets) > 0:
		go_to(compute_nearest(targets).global_position)
		log_strategy('go to card')
		return
		
	forget_current_target_location()
	
func _on_NavigationAgent2D_target_reached():
	# if we arrived on a card, attempt to select it
	request_fire()

func _on_battle_start():
	if not is_inside_tree(): # attempts to avoid a crash that happened in DraftArena after a match of Diamond Minefield was already finished
		return
		
	for card in get_tree().get_nodes_in_group('Card'):
		if card.get_content() == MinefieldManager.MINE and randf() < 0.85:
			mines_memory[card] = true
			
