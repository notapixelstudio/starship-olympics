extends Node

const LIVES = 5
const species = ["robolords", "mantiacs", "trixens"]

var gameover = false
var enemy = "CPU"
var available_species =[]
var unlocked setget get_available_species
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
	

func get_available_species(new_value):
	unlocked=new_value
	print("prima")
	for i in range(0, unlocked):
		available_species.append(species[i])
	
func reset():
	available_species = species
	scores = {
	'p1': LIVES,
	'p2': LIVES
	}
	gameover = false
	
func get_state():
	var save_dict = {
		lives=5,
		unlocked=2
	}
	return save_dict

func load_state(data):
	for attribute in data:
		set(attribute, data[attribute])
	