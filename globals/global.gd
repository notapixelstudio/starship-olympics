extends Node

const LIVES = 5
const species = ["robolords", "mantiacs", "trixens"]

var gameover = false
var enemy = "CPU"
var available_species =[]
var unlocked = len(species) setget get_available_species
var chosen_species = {
	'p1': 1,
	'p2': 0
}
var scores = {
	'p1': LIVES,
	'p2': LIVES
}

func _ready():
	# if we want to save data from global
	add_to_group("persist")
	reset_selection()

func get_available_species(new_value):
	unlocked=new_value
	reset_selection()

func reset():
	available_species = []
	reset_selection()
	scores = {
	'p1': LIVES,
	'p2': LIVES
	}
	gameover = false
	
	
func reset_selection():
	for i in range(0, unlocked):
		available_species.append(species[i])
		
func get_state():
	var save_dict = {
		lives=5,
		unlocked=2
	}
	return save_dict

func load_state(data):
	for attribute in data:
		set(attribute, data[attribute])
