extends CPUBrain

var memory := {}

func _ready():
	._ready()
	Events.connect('card_revealed', self, '_on_card_revealed')
	
func think():
	var targets
	
	set_stance('quiet') # we can't shoot here
	log_strategy('')
	
	targets = get_tree().get_nodes_in_group('Card')
	if len(targets) > 0:
		go_to(targets[0].global_position)
		log_strategy('go to card')
		return
	
func _on_NavigationAgent2D_target_reached():
	# if we arrived on a card, attempt to select it
	request_fire()
	
func _on_card_revealed(card: Card):
	remember(card)

func remember(card):
	var content = card.get_content()
	if not memory.has(content):
		memory[content] = []
	memory[content].append(card)
