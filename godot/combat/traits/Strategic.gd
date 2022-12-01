extends Trait

# TBD get_strategic_value(ship) needs to be mandatory (validate should check for it)

# deprecated
func get_strategy(ship, distance, game_mode):
	if host.has_method('get_strategy'):
		return host.get_strategy(ship, distance, game_mode)
	
	return {}
