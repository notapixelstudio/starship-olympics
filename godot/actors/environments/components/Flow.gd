extends Component

enum TYPE { center, direction }
export(TYPE) var type = TYPE.center

export var vector_or_point : Vector2 = Vector2(0,0)
export var charge : int = -1 # attractive

func get_flow_vector(pos) -> Vector2:
	if type == TYPE.center:
		return (pos-(get_host().position+vector_or_point)).normalized() * charge # mmm a bit of logic here
	elif type == TYPE.direction:
		return vector_or_point.normalized() * charge
	else:
		return Vector2() # this is to quiet the compiler
	