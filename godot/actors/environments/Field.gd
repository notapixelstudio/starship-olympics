tool

extends Node2D

export var shape : Resource setget set_shape # FIXME should be GShape

func set_shape(value):
	shape = value
	if Engine.is_editor_hint():
		_refresh()
		
func _ready():
	_refresh()
	
func _refresh():
	$Polygon2D.polygon = shape.to_PoolVector2Array()
	