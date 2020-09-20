extends Component

var destination = null

func set_destination(dest):
	destination = dest
	
func is_teleporting():
	return destination != null
	
func get_destination():
	return destination
	
func teleport_done():
	destination = null
	
