extends Node

class_name InfoChampion

var player: Dictionary # From InfoPlayer
var session_info: Dictionary # from session


func to_dict():
	return {
		"player": player,
		"session": session_info
	}
