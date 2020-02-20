extends MapCell

export var active : bool = false setget set_active
export var value_name : String = "win"
export var global_option : bool = true
export var node_owner_path : NodePath
export var text : String = ''

var node_owner

func set_active(value):
	active = value
	if not is_inside_tree():
		yield(self, "ready") 
	node_owner.set(value_name, active)
	refresh()
	
func refresh():
	if active:
		$CheckBox.play('true')
	else:
		$CheckBox.play('empty')
	
func _ready():
	while not node_owner:
		node_owner = global if global_option else get_node(node_owner_path)
	refresh()
	$Label.text = text
	
func toggle_active():
	set_active(not active)
	
func act(cursor):
	toggle_active()
	.act(cursor)
