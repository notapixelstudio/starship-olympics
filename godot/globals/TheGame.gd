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

func to_log_dict() -> Dictionary:
	var human_players_dicts := []
	for player in self.get_human_players():
		human_players_dicts.append(player.to_dict())
		
	return {
		'game_uuid': self.get_uuid(),
		'human_players': human_players_dicts,
		'human_players_count': len(human_players_dicts)
	}
