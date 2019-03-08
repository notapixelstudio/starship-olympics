tool

extends Node2D

func _ready():
	_refresh()
	
	get_tree().connect('tree_changed', self, '_refresh')
	
func _on_GShape_changed():
	_refresh()
	
func _refresh():
	var gshape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed', self, '_on_GShape_changed'):
		gshape.connect('changed', self, '_on_GShape_changed')
		
	$Polygon2D.polygon = gshape.to_PoolVector2Array()
	$Area2D/CollisionShape2D.shape = gshape.to_Shape2D()
	
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func _get_configuration_warning():
	if not get_gshape():
		return 'Please provide a GShape as child node to define the geometry.\n'
	return ''
	