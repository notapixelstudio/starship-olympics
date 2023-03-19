extends CPUBrain

var territory

func _ready():
	._ready()
	
#	Events.connect("holdable_obtained", self, '_on_holdable_obtained')
#	Events.connect("holdable_lost", self, '_on_holdable_lost')
	
	for t in get_tree().get_nodes_in_group('territory'):
		if t.get_player() == controllee.get_player():
			territory = t

func think():
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	# if I have the banner
	if controllee.get_cargo().check_class(Ball):
		if is_banner_on_my_territory():
			# escape
			targets = get_tree().get_nodes_in_group('Ship')
			if len(targets) > 0:
				var escape_vector := Vector2.ZERO
				for target in targets:
					if target != controllee:
						escape_vector -= target.get_target_destination() - global_position
						
				go_to(global_position + escape_vector)
				log_strategy('escape')
				return
		else:
			# reach territory
			go_to(territory.global_position)
			log_strategy('reach territory')
			return
	
	# if no one has the banner
	targets = get_tree().get_nodes_in_group('Ball')
	if len(targets) > 0:
		# go get it
		go_to(targets[0].global_position)
		log_strategy('chase banner')
		return
	
	# if enemy has the banner
	targets = get_tree().get_nodes_in_group('Ship')
	if len(targets) > 0:
		# try to steal the banner
		for target in targets:
			if target != controllee and target.get_cargo().check_class(Ball):
				set_stance('aggressive')
				go_to(target.get_target_destination())
				log_strategy('chase ship')
				return

#func _on_holdable_obtained(holdable, ship):
#	if ship != controllee:
#		return
#	set_navigation_layer('holder')
#
#func _on_holdable_lost(holdable, ship):
#	if ship != controllee:
#		return
#	set_navigation_layer('default')

func is_banner_on_my_territory() -> bool:
	return territory.has_banner()
	
