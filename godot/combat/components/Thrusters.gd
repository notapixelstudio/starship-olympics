extends Component

export var default_damp : float = 2
export var viscous_damp : float = 6

var hindrances : int = 0

func add_hindrance():
	hindrances += 1

func reset_hindrances():
	hindrances = 0
	
func apply_damp():
	if hindrances <= 0:
		get_host().linear_damp = default_damp
	else:
		get_host().linear_damp = viscous_damp
		
