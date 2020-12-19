extends Trait

func get_strategy(ship, distance, game_mode):
	if host.has_method('get_strategy'):
		return host.get_strategy(ship, distance, game_mode)
	
	return {}
