extends CPUBrain

var memory := [] # Array[String] - card.name
var card_one = null

func _ready():
	._ready()
	Events.connect('card_revealed', self, '_on_card_revealed')
	Events.connect('card_taken', self, '_on_card_taken')
	
func think():
	var targets
	
	set_stance('quiet') # we can't shoot here
	log_strategy('')
	
	var remembered_targets = []
	for card in get_tree().get_nodes_in_group('Card'):
		if card.is_face_down() and card.name in memory:
			remembered_targets.append(card)
	
	targets = []
	
	if card_one == null or not knows_where_to_find_another(card_one, remembered_targets):
		# tap the nearest card
		for card in get_tree().get_nodes_in_group('Card'):
			if card.is_face_down():
				targets.append(card)
		if len(targets) > 0:
			go_to(compute_nearest(targets).global_position)
			log_strategy('go to nearest')
		else:
			forget_current_target_location()
	else:
		# tap a remembered card
		for c in remembered_targets:
			if c.get_content() == card_one.get_content():
				targets.append(c)
		
		if len(targets) > 0:
			go_to(compute_nearest(targets).global_position)
			log_strategy('go to remembered')
		else:
			forget_current_target_location()
	
func _on_NavigationAgent2D_target_reached():
	# if we arrived on a card, attempt to select it after a random time
	$ReleaseTimer.wait_time = randf()
	$ReleaseTimer.start()
	
func _on_card_revealed(card: Card) -> void:
	if randf() < 0.85:
		remember(card)
	
func _on_card_taken(card: Card, player: InfoPlayer, ship: Ship):
	if ship != controllee:
		return
		
	if card_one == null:
		card_one = card
	else:
		card_one = null

func remember(card) -> void:
	memory.append(card.name)

func knows_where_to_find_another(card, remembered_targets) -> bool:
	for target in remembered_targets:
		if target != card and target.get_content() == card.get_content():
			return true
	return false
	
