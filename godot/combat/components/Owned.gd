extends Component

var owned_by : Ship setget set_owned_by, get_owned_by

func set_owned_by(value):
	owned_by = value
	
func get_owned_by():
	return owned_by
	