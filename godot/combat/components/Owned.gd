extends Component

class_name Owned

var owned_by : Ship :
	get:
		return owned_by # TODOConverter40 Copy here content of get_owned_by
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_owned_by

func set_owned_by(value):
	owned_by = value
	
func get_owned_by():
	return owned_by
	
