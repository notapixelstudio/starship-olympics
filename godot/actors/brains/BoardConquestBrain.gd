extends CPUBrain

var premidgame := false
var midgame := false
var ending := false
var stealer := false

func think():
	var targets
	
	if not premidgame:
		premidgame = global.the_match.get_time_left() <= ( 20 + (randi() % 4) )
	if premidgame and not midgame:
		midgame = global.the_match.get_time_left() <= ( 14 + (randi() % 6) )
		if midgame:
			stealer = randf() > 0.7
	if midgame and not ending:
		ending = global.the_match.get_time_left() <= ( 3 + (randi() % 4) )
		
	if midgame:
		random_dash_p = 0.008 # doubled
		if stealer:
			stealer = randf() < 0.999
		
	set_stance('quiet') # we can't shoot in this minigame
	log_strategy('')
	
	targets = get_tree().get_nodes_in_group('Tile')
	var best = null
	var priority = null
	for target in targets:
		var strategic_value = target.get_strategic_value(controllee, premidgame, midgame, ending, stealer)
		var distance = max(global_position.distance_to(target.global_position), 0.1) # avoid divisions by zero
		if not strategic_value:
			continue
		#if strategic_value 
		var p = strategic_value / distance
		if not best or p > priority:
			best = target
			priority = p
			
	if best:
		go_to(best.global_position + controllee.linear_velocity*0.15) # try to keep moving, aim over the target
		if ending:
			log_strategy('desperate')
		elif midgame and not stealer:
			log_strategy('filler')
		elif midgame and stealer:
			log_strategy('stealer')
		elif premidgame:
			log_strategy('fortifier 30')
		else:
			log_strategy('fortifier 50')
		return
	
	forget_current_target_location()
