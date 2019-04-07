extends Component

enum STATUS { full, reduced }

export (STATUS) var status = STATUS.full

export var full_speed : float = 50
export var reduced_speed : float = 20

func set_full_speed():
	status = STATUS.full

func set_reduced_speed():
	status = STATUS.reduced
	
func get_speed():
	if status == STATUS.full:
		return full_speed
	if status == STATUS.reduced:
		return reduced_speed
		