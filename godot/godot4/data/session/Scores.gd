extends Node

class_name Scores

var uuid : String
var nickname: String
var players : Array[Player]
var timestamp_local : String
var timestamp : String
var standings: Array[Standing]
var winners: Array[String] # team name
var remaining_time: float
var time: float
var max_score: int
var minigame_name: String
var score: float
var achievement: String



class Standing:
	var team: String
	var score: float
	var achievement: String
	
	func _init(data: Dictionary):
		team = data.get("team")
		score= data.get("score")
		achievement = data.get("achievement", "")
	
	func to_dictionary() -> Dictionary:
		return {
			"team": team,
			"score": score,
			"achievement": achievement
		}


func _init(data: Dictionary):
	uuid = UUID.v4()
	timestamp_local = Time.get_datetime_string_from_system(false, true)
	timestamp = Time.get_datetime_string_from_system(true, true)
	players = data["players"]
	remaining_time = data["remaining_time"]
	time = data["time"]
	max_score = data["max_score"]
	minigame_name = data["minigame"]
	score = data.get("standings")[-1].get("score")
	achievement = data.get("medal")
	# standings
	for stand in data.get("standings"):
		standings.append(Standing.new(stand))
	winners = data["winners"]
	print(JSON.stringify(to_dictionary()))
	
func to_dictionary():
	var players_dict = []
	for p in players:
		players_dict.append(p.to_dictionary())
	var standings_dictionary = []
	for s in standings:
		standings_dictionary.append(s.to_dictionary())
	return {
		"uuid": uuid,
		"nickname": nickname,
		"players": players_dict, 
		"timestamp": timestamp,
		"timestamp_local": timestamp_local,
		"winners": winners, 
		"standings": standings_dictionary,
		"remaining_time": remaining_time,
		"time": time,
		"max_score": max_score,
		"minigame": minigame_name,
		"score": score,
		"achievement": achievement,
	}
