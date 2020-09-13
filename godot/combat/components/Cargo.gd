extends Component

var what

func load(value):
	what = value
	enable()
	
func unload():
	var stuff = what
	what = null
	disable()
	return stuff
	
