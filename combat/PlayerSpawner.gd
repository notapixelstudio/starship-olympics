extends Node

class_name PlayerSpawner

export (String) var controls = "kb1"
export (Resource) var battler_template
# temporary for cpu
export (bool) var cpu = false

var id : String
var uid : int
var info_player : InfoPlayer

func is_cpu()->bool:
	#return info_player.cpu
	return cpu