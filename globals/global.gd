extends Node

const LIVES = 5
const SPECIES = ["robolords", "mantiacs", "trixens"]
var gameover = false
var enemy = "CPU"
var available_species = ["robolords", "mantiacs", "trixens"]
var chosen_species = {
	'p1': 1,
	'p2': 0
}
var scores = {
	'p1': LIVES,
	'p2': LIVES
}

func reset():
	available_species = SPECIES
	scores = {
	'p1': LIVES,
	'p2': LIVES
	}
	gameover = false