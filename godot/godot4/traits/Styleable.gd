extends Trait
class_name Styleable

@export var style : Style

func get_style_from_ancestor_or_self():
	var node = host
	var current_style = style
	while not current_style and node.has_node('..'):
		node = node.get_parent()
		if traits.has_trait(node, 'Styleable'):
			current_style = traits.get_trait(node, 'Styleable').style
		
	return current_style
