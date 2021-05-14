extends Trait

export var anchor_body_path : NodePath

func validate():
	.validate()
	
func get_anchor_body():
	return get_node(anchor_body_path)
