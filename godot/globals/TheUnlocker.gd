extends Node

const SPECIES_PATH = "res://selection/characters"
const GAMES_PATH = "res://combat/modes"
const SET_PATH = "res://map/planets/sets"

# status
const INVISIBLE = "invisible"
const LOCKED = "locked"
const UNLOCKED = "unlocked"

export (String, "invisible", "locked", "unlocked") var status 


# templates
onready var species_resources: Dictionary = get_resources(SPECIES_PATH)  # {int : Resources}
onready var species_discovered_scene = preload("res://special_scenes/UnlockedSpecies.tscn")
onready var games_resources: Dictionary = get_resources(GAMES_PATH)  # {int : Resources}
onready var set_resources: Dictionary = get_resources(SET_PATH)  # {int : Resources}

var unlock_time = false # flag to know if there is something to unlock

func what_to_unlock() -> bool:
	return unlock_time
	
func will_unlock():
	# This function will activate a flag that will be used to set the flag 
	# to unlock
	unlock_time = true
	
func _ready():
	add_to_group("persist")
	unlock_time = false
	

var map_unlocked = true # If the map has been unlocked or not

func is_map_unlocked() -> bool:
	return map_unlocked

func get_resources(base_path: String) -> Dictionary:
	var ret = {}
	var resources = global.dir_contents(base_path, "", ".tres")
	for filename in resources:
		var this_res = load(base_path.plus_file(filename))
		var res_id = this_res.id
		ret[res_id] = this_res
	return ret


func _unlock_species(species: String):
	unlocked_species[species] = true
	persistance.save_game()

func unlock_set(set: String) -> void:
	unlocked_sets[set] = true
	persistance.save_game()

var unlocked_paths = {
	
}
func unlock_path(path_id: String) -> void:
	unlocked_paths[path_id] = true
	persistance.save_game()
	
func get_status_path(path_id)->bool:
	return unlocked_paths.get(path_id, "invisible")
	
func get_status_location(loc_id)-> bool:
	return unlocked_locations.get(loc_id, "invisible")
	
var unlocked_locations = {
	
}

func unlock_location(loc_id: String) -> void:
	unlocked_locations[loc_id] = true
	persistance.save_game()
	
var unlocked_sets = {
	"drones": "invisible",
	"trinkets": "invisible",
	"snake": "invisible",
	"asteroids": "invisible",
	"labs": "invisible",
	"core": true,
	"death": "invisible",
	"sports": "invisible",
	"beach": "invisible",
}

# this can have only TWO status: UNLOCKED, LOCKED 
var unlocked_games = {
	
}

func get_status_game(game_id)-> String:
	return unlocked_games.get(game_id, LOCKED)
	
func unlock_game(game_id: String) -> void:
	# If fails means that we already unlocked this game
	assert(self.get_status_game(game_id) == TheUnlocker.LOCKED)
	self.unlocked_games[game_id] = TheUnlocker.UNLOCKED
	persistance.save_game()
	
# dictionary of SPECIES with some values (like a bool unlocked)
var unlocked_species = {
	"mantiacs_1": true,
	"robolords_1": true,
	"trixens_1": true,
	"umidorians_1": true,
	"pentagonions_1": true,
	"auriels_1": true,
	"robolords_2": false,
	"trixens_2": false,
	"auriels_2": false,
	"umidorians_2": false,
	"mantiacs_2": false
}


func get_ordered_species() -> Array:
	var ordered_species = get_unlocked()
	ordered_species.sort_custom(self, 'compare_by_id')
	return ordered_species


func compare_by_id(a: Species, b: Species):
	return a.species_id < b.species_id


func unlock_species():
	get_tree().paused = true
	var unlocked_scene = species_discovered_scene.instance()
	add_child(unlocked_scene)
	yield(get_tree().create_timer(3), "timeout")
	unlocked_scene.queue_free()
	get_tree().paused = false


func get_unlocked() -> Array:
	"""
	Get all available unlocked species. 
	@return: Array[resource (Species)] of Species
	"""
	var available: Array = []
	for species in unlocked_species:
		if unlocked_species[species]:
			available.append(species_resources[species])

	return available


func load_state(data: Dictionary):
	"""
	Set back everything we need to load
	"""
	for attribute in data:
		set(attribute, data[attribute])


func get_state():
	"""
	get_state will return everything we need to be persistent in the game
	"""
	return {
		unlocked_sets = unlocked_sets,
		unlocked_games = unlocked_games,
		unlocked_species = unlocked_species,
		unlocked_locations=unlocked_locations,
		unlocked_paths=unlocked_paths,
		map_unlocked=map_unlocked
		
	}
