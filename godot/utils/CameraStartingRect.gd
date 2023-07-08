@tool
extends Polygon2D

var gshape : GShape

func _ready():
	for node in get_children():
		if node is GShape:
			gshape = node
			break
	gshape.connect('changed', Callable(self, '_on_gshape_changed'))
	refresh_shape()
	
	if not Engine.is_editor_hint():
		visible = false
	
func _on_gshape_changed():
	refresh_shape()
	
func add_child(node, legible_unique_name=false):
	super.add_child(node, legible_unique_name)
	if node is GShape:
		gshape = node
		gshape.connect('changed', Callable(self, '_on_gshape_changed'))
		refresh_shape()
	
func refresh_shape():
	polygon = gshape.to_closed_PoolVector2Array()

func get_rect_extents():
	var size = gshape.get_extents()
	return Rect2(-1.0 * size / 2 , size)
