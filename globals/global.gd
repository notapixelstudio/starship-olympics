extends Node

const LIVES = 3
var gameover = false
var enemy = "CPU"
var avalaible_species = ["robolords", "mantiacs", "trixens"]
var chosen_species = {
	'p1': 0,
	'p2': 1
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