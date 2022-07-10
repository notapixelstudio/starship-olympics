extends MapCell

export var active : bool = false setget set_active
export var value_name : String = "win"
export var inverted : bool = false
export var global_option : bool = true
export var node_owner_path : NodePath
export var text : String = ''

var node_owner
var enabled = true

func initialize(value):
	self.active = value
	
func set_active(value):
	active = value
	if not is_inside_tree():
		yield(self, "ready") 
	node_owner.set(value_name, active)
	refresh()
	
func set_inverted(value):
	inverted = value
	refresh()
	
func refresh():
	if active and not inverted or not active and inverted:
		$CheckBox.play('true')
	else:
		$CheckBox.play('empty')
		
	if enabled:
		modulate = Color(1,1,1,1)
	else:
		modulate = Color(1,1,1,0.3)
	
func _ready():
	while not node_owner:
		node_owner = global if global_option else get_node(node_owner_path)
	refresh()
	$Label.text = text
	
func toggle_active():
	set_active(not active)
	
func act(cursor):
	if not enabled:
		cursor.on_sth_pressed(false)
		return
		
	toggle_active()
	.act(cursor)
	cursor.on_sth_pressed()
	if active and not inverted or not active and inverted:
		$switch_on.play()
	else:
		$switch_off.play()

func set_enabled(v):
	enabled = v
	refresh()
	
func _on_master_updated(active):
	set_enabled(active)
