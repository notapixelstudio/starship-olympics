extends Component

var list = []

func add_to_list(who):
	if not who in list:
		list.append(who)

func get_list():
	return list

func get_strategy(ship, distance, game_mode):
	if get_host().has_method('get_strategy'):
		return get_host().get_strategy(ship, distance, game_mode)
	else:
		return { "seek": 1 } # default behavior for strategic objects
