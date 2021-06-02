tool
extends Area2D
class_name DeepGel

var gshape : GShape

func _ready():
	for node in get_children():
		if node is GShape:
			gshape = node
			break
	gshape.connect('changed', self, '_on_gshape_changed')
	refresh_shape()
	
func _on_gshape_changed():
	refresh_shape()
	
func add_child(node, legible_unique_name=false):
	.add_child(node, legible_unique_name)
	if node is GShape:
		gshape = node
		gshape.connect('changed', self, '_on_gshape_changed')
		refresh_shape()
	
func refresh_shape():
	var polygon = gshape.to_closed_PoolVector2Array()
	$Polygon2D.polygon = polygon
	$CollisionPolygon2D.polygon = polygon
	$Line2D.points = polygon
	
func is_escapable():
	return false
	
