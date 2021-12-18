extends Node

class_name TheGame

var uuid : String
var players : Array

func _init():
	uuid = UUID.v4()
	
func get_uuid() -> String:
	return uuid

func set_players(_players : Array) -> void:
	players = _players
	
func get_players() -> Array: # of InfoPlayer
	return players
	
func get_number_of_players() -> int:
	return len(players)
	
func get_number_of_human_players() -> int:
	var count := 0
	for player in players:
		if not player.cpu:
			count += 1
	return count
	
func get_last_winner() -> InfoPlayer:
	var best_player = null
	var best_score = 0
	for player in players:
		var new_score = player.get_session_score_total()
		if new_score > best_score:
			best_player = player
			best_score = new_score
			
	if best_score < global.win:
		return null
		
	return best_player
	
func reset_players():
	for player in players:
		player.reset()
		
func to_log_dict() -> Dictionary:
	var players_dicts := []
	for player in players:
		players_dicts.append(player.to_dict())
		
	return {
		'game_uuid': self.get_uuid(),
		'players': players_dicts,
		'players_count': get_number_of_players(),
		'human_players_count': get_number_of_human_players()
	}
