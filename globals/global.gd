extends Node

const width = 1280
const height = 720

const min_lives = 1
var lives = 5
const max_lives = 10

# levels
var level
var array_level

const species = ["mantiacs","robolords", "trixens", "another"]

# default unlocked species. The idea is put the locked one to "blank"
var unlocked_species = ["mantiacs","robolords","trixens", "another"]

var from_scene = ProjectSettings.get_setting("application/run/main_scene")

var debug = false

var gameover = false
var standoff = false

var changed = false
var enemy = "Player"
var available_species =[]

# TODO: this will disappear
var min_unlocked = 1
var unlocked = 4 setget get_available_species
var max_unlocked = 4

var max_players = 4
var num_players = 0

# chosen_species contains the choses species as string
var chosen_species = {}
var scores = {}

var this_run_time = 0

func _ready():
	# get the list of levels
	array_level = dir_contents("res://screens/game_screen/levels")
	if not level:
		level = array_level[0]
	# setting players dictionary
	for i in range(1,max_players+1):
		var pname = "p"+str(i)
		scores[pname] = lives
		chosen_species[pname] = species[i-1]

	# if we want to save data from global
	add_to_group("persist")
	reset()

func get_available_species(new_value):
	unlocked=new_value
	reset_selection()

func reset():
	reset_selection()
	for i in range(1,max_players+1):
		var pname = "p"+str(i)
		scores[pname] = lives
	gameover = false
	
	
func reset_selection():
	available_species =[]
	for i in range(0, len(unlocked_species)):
		available_species.append(unlocked_species[i])
		
func get_state():
	# for debug purposes
	unlocked_species = []
	for i in range(0, unlocked):
		unlocked_species.append(species[i])

	var save_dict = {
		lives=int(lives),
		unlocked_species=unlocked_species,
		unlocked=int(unlocked),
		changed=bool(changed),
		level=level
	}
	return save_dict

func load_state(data):
	for attribute in data:
		set(attribute, data[attribute])


func dir_contents(path):
	var dir = Directory.new()
	var list_files = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(".tscn"):
					list_files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list_files