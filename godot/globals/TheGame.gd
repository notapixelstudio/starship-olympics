extends Node

class_name TheGame

var uuid : String
var human_players : Array

func _init():
	uuid = UUID.v4()
	
func get_uuid() -> String:
	return uuid

func set_human_players(players : Array) -> void:
	human_players = players
	
func get_human_players() -> Array:
	return human_players
