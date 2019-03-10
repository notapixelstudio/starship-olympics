tool

extends Node2D

func _ready():
	refresh()
	
func _on_GShape_changed():
	refresh()
	
func refresh():
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
	
signal entered
func _on_Area2D_body_entered(body):
	emit_signal("entered", self, body)
	
signal exited
func _on_Area2D_body_exited(body):
	emit_signal("exited", self, body)
	