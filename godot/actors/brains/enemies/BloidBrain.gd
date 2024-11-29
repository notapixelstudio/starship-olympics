extends CPUBrain

@export var go_to_center_p := 0.1

#var random_preference : int
#
#func _ready():
	#super._ready()
	#random_preference = randi()
	
func think():
	var targets
	
	set_stance('quiet') # we can't shoot in this minigame
	log_strategy('')
	
	targets = get_tree().get_nodes_in_group('Ship')
	if len(targets) > 0:
		var nearest = compute_nearest(targets)
		go_to(nearest.global_position)
		#go_to(targets[random_preference%len(targets)].global_position)
		log_strategy('chase ship')
		return
	
	if randf() < go_to_center_p:
		go_to(Vector2(0,0))
		log_strategy('go to center')
	else:
		forget_current_target_location()
