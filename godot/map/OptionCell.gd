extends MapCell

export var value_name : String = "win"
export var selection : Array = [1, 3, 5]
export var global_option : bool = true
var index : int = 0

func _ready():
	for child in get_children():
		child.visible = false
	var value = int(global.get(value_name))
	index = selection.find(value)
	get_child(index).visible = true
	
func act(cursor):
	index = (index + 1) % len(selection)
	
	for child in get_children():
		child.visible = false
		
	get_child(index).visible = true
	global.set(value_name, selection[index])
	.act(cursor)

