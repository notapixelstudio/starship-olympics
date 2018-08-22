extends Node

const LIVES = 5
var gameover = false
var enemy = "CPU"
var avalaible_species = ["robolords", "mantiacs", "trixens"]
var chosen_species = {
	'p1': 1,
	'p2': 0
}
var scores = {
	'p1': LIVES,
	'p2': LIVES
}

func reset():
	scores = {
	'p1': LIVES,
	'p2': LIVES
	}
	gameover = false