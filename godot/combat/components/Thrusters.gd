extends Component

export var default_damp : float = 2
export var viscous_damp : float = 8

var hindrance_count : int = 0

func add_hindrance():
	hindrance_count += 1

func remove_hindrance():
	hindrance_count -= 1
	
func apply_damp(sth : RigidBody2D):
	if hindrance_count <= 0:
		sth.linear_damp = default_damp
	else:
		sth.linear_damp = viscous_damp
		