extends Node

var lives = 1
const species = ["robolords", "mantiacs", "trixens"]

var from_scene

var gameover = false
var changed = false
var enemy = "CPU"
var available_species =[]
var unlocked = 2 setget get_available_species
var chosen_species = {
	'p1': 1,
	'p2': 0
}
var scores = {
	'p1': lives,
	'p2': lives
}

func _ready():
	# if we want to save data from global
	add_to_group("persist")
	reset()

func get_available_species(new_value):
	unlocked=new_value
	reset_selection()

func reset():
	reset_selection()
	scores = {
	'p1': lives,
	'p2': lives
	}
	gameover = false
	
	
func reset_selection():
	available_species =[]
	for i in range(0, unlocked):
		available_species.append(species[i])
		
func get_state():
	var save_dict = {
		lives=5,
		unlocked=3,
		changed=true
	}
	return save_dict

func load_state(data):
	for attribute in data:
		set(attribute, data[attribute])
