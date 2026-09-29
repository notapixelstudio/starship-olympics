extends Trait
class_name Styleable

@export var style : Style

var _current_style : Style

func _ready():
	super()
	cascade_styles()
	
func cascade_styles() -> void:
	var node = host
	_current_style = style
	while not _current_style and node.has_node('..'):
		node = node.get_parent()
		if traits.has_trait(node, 'Styleable'):
			_current_style = traits.get_trait(node, 'Styleable').style
		
func apply_current_style() -> void:
	get_host().set_style(_current_style)

static func reapply_all_styles() -> void:
	for styleable in traits.get_all('Styleable'):
		if styleable.get_host().has_method('set_style'):
			styleable.cascade_styles()
			styleable.apply_current_style()
