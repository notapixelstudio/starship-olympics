extends MapCell

export var var_name : String = "win"
export var selection : Array = []
export var global_option : bool = true
export var node_owner_path : NodePath
var index : int = 0
var node_owner

export var description = "{_} victories"
onready var sprite = $Sprite
onready var label = $Label

func _ready():
	while not node_owner:
		node_owner = global if global_option else get_node(node_owner_path)
	if selection:
		initialize()


func initialize( starting_from: int = 0, options: int = 0):
	
	var new_selection = []
	for i in range(starting_from, options):
		new_selection.append(i)
	
	if new_selection:
		selection = new_selection
	
	var value = int(node_owner.get(var_name))
	index = selection.find(value) if selection.find(value)>=0 else 0
	node_owner.set(var_name, selection[index])
	var selected_value = selection[index]

	sprite.texture = sprite.get_child(selected_value).texture
	label.text = description.format({"_": selected_value})
	
func act(cursor):
	index = (index + 1) % len(selection)
	
	#get_child(index).visible = true
	node_owner.set(var_name, selection[index])

	sprite.texture = sprite.get_child(selection[index]).texture
	label.text = description.format({"_": selection[index]})
	.act(cursor)
	cursor.on_sth_pressed()
