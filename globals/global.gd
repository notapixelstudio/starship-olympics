extends Node

const min_lives = 1
var lives = 5
const max_lives = 10

const species = ["mantiacs","robolords", "trixens"]

# default unlocked species. The idea is put the locked one to "blank"
var unlocked_species = ["mantiacs","robolords"]

var from_scene = ProjectSettings.get_setting("application/run/main_scene")

var debug = false

var gameover = false
var standoff = false

var changed = false
var enemy = "CPU"
var available_species =[]

# TODO: this will disappear
var unlocked = 2 setget get_available_species

var default_players = 2
var chosen_species = {}
var scores = {}

func _ready():
	# setting players dictionary
	for i in range(1,default_players+1):
		var pname = "p"+str(i)
		scores[pname] = lives
		chosen_species[pname] = i-1

	# if we want to save data from global
	add_to_group("persist")
	print(scores)
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
	for i in range(0, len(unlocked_species)):
		available_species.append(unlocked_species[i])
		
func get_state():
	var save_dict = {
		lives=int(lives),
		unlocked_species=unlocked_species,
		unlocked=int(unlocked),
		changed=bool(changed)
	}
	return save_dict

func load_state(data):
	print(data)
	for attribute in data:
		set(attribute, data[attribute])
