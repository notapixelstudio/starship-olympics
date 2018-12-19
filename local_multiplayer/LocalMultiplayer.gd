extends Node

onready var selection_screen = $SelectionScreen

var info_player = {
	"species" : "mantiacs",
	"cpu": false,
	"controls" : "kb1",
	"playable" : true
	}
	
var players : Dictionary
var test_controls = ["kb1", "kb2", "cpu", "no"]
func _ready():
	
	selection_screen.initialize(global.get_unlocked(), test_controls)