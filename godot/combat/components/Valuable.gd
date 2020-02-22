extends Component

var list = []

func add_to_list(who):
	if not who in list:
		list.append(who)

func get_list():
	return list
