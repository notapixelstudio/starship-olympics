extends Node

class_name InfoChampion

var player: Dictionary # From InfoPlayer
var session_info: Dictionary # from session

const PATH_FILE_CHAMPIONS = "user://hall_of_fame.json"

func to_dict():
	return {
		"player": player,
		"session_info": session_info
	}

func store():
	global.write_into_file(PATH_FILE_CHAMPIONS, self.to_dict())
