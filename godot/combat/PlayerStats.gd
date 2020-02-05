extends Node
# This script handles scores and in-game stats

class_name PlayerStats

var id : String
var info # InfoPlayer
var team : String
var kills : int = 0
var selfkills : int = 0
var lives : int = 10
var deaths : int = 0
var bombs: int = 0
var collectables : int  =0
var score = 0.0

func get_session_score():
	return info.session_score

