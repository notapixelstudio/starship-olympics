extends Trait

func validate():
	.validate()
	assert(host.has_signal('goal_done')) # (player, goal, position, points=1)
	
