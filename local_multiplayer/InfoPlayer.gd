extends Resource

class_name InfoPlayer

var controls : String = "kb1"
var species : String
var cpu: bool = false
var playable : bool = true
var lives : int = 10
var deaths : int = 0
var collectables : int  =0

func update_death():
	deaths += 1
	return deaths

func update_collectables():
	collectables += 1
	return collectables