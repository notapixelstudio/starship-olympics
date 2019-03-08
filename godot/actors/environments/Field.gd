tool

extends Node2D

export var shape : Resource setget set_shape # FIXME should be GShape
var gshape : GRect

func set_shape(value):
	shape = value
	gshape = shape
	if Engine.is_editor_hint():
		_refresh()
		
func _ready():
	_refresh()
	
func _refresh():
	$Polygon2D.polygon = gshape.points
	