extends Node

class_name Hosted

## hosted should explicit set the host attached to
@export var host: Node : get = get_host

func get_host() -> Node:
	return host 

func _ready():
	if host == null:
		host = get_parent()
