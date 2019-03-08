tool

extends Node2D

func _ready():
	_refresh()
	
func _on_GShape_changed():
	_refresh()
	
func _refresh():
	$Polygon2D.polygon = $GShape.to_PoolVector2Array()
	$Area2D/CollisionShape2D.shape = $GShape.to_Shape2D()
	