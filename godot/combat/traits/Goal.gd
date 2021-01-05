extends Trait

func validate():
	.validate()
	assert(host.has_method('get_score'))
	assert(host.has_method('do_goal')) # (player, position)
	assert(host.has_signal('goal_done')) # (player, goal, position)
	
