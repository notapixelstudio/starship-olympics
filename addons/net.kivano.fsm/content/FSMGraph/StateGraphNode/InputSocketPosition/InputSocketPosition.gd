tool
extends Control

func _ready():
	pass

func getParentGraphNode():
	return get_parent().get_parent();
