extends Component

func get_strategy(ship, distance, game_mode):
	if get_host().has_method('get_strategy'):
		return get_host().get_strategy(ship, distance, game_mode)
	else:
		return { "seek": 1 } # default behavior for strategic objects
