tool
extends Area2D

class_name Ice

func _ready():
	refresh()
	
func _on_GShape_changed():
	refresh()
	
func refresh():
	var gshape : GShape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed', self, '_on_GShape_changed'):
		gshape.connect('changed', self, '_on_GShape_changed')
		
	var polygon = gshape.to_PoolVector2Array()
	$CollisionPolygon2D.polygon = polygon
	$Polygon2D.polygon = polygon
	$Line2D.points = gshape.to_closed_PoolVector2Array()
	
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
