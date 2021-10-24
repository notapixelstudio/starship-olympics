extends Node

const SPECIES_PATH = "res://selection/characters"
const GAMES_PATH = "res://combat/modes"
const SET_PATH = "res://map/planets/sets"

# status
const HIDDEN = "hidden"
const LOCKED = "locked"
const UNLOCKED = "unlocked"

export (String, "hidden", "locked", "unlocked") var status 


# templates
onready var species_resources: Dictionary = get_resources(SPECIES_PATH)  # {int : Resources}
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
	
	Events.connect('sth_unhid', self, '_on_sth_unhid')
	Events.connect('sth_unlocked', self, '_on_sth_unlocked')

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

func unhide_set(set: Set) -> void:
	unlocked_sets[set.get_id()] = LOCKED
	persistance.save_game()
	
func unlock_set(set: Set) -> void:
	unlocked_sets[set.get_id()] = UNLOCKED
	persistance.save_game()

var unlocked_paths = {
	
}
func unlock_path(path_id: String) -> void:
	unlocked_paths[path_id] = true
	persistance.save_game()
	
func get_status_path(path_id)->bool:
	return unlocked_paths.get(path_id, "hidden")
	
func get_status_location(loc_id)-> bool:
	return unlocked_locations.get(loc_id, "hidden")
	
var unlocked_locations = {
	
}

func unlock_location(loc_id: String) -> void:
	unlocked_locations[loc_id] = true
	persistance.save_game()
	
var unlocked_sets = {
	"core": UNLOCKED,
	"diamonds": HIDDEN,
	"ice": HIDDEN,
	"survival": HIDDEN,
	"casino": HIDDEN,
	"snake": HIDDEN,
	"sports": LOCKED,
	"asteroids": HIDDEN,
	"conquest": HIDDEN,
	"death": LOCKED,
	"crown": HIDDEN,
	"cards": LOCKED,
}

# this can have only TWO status: UNLOCKED, LOCKED 
var unlocked_games = {
	
}

func get_status_game(game_id)-> String:
	return unlocked_games.get(game_id, LOCKED)
	
func get_status_set(set_id)-> String:
	return unlocked_sets.get(set_id, LOCKED)
	
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
	"eelectrons_1": true,
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

func _on_sth_unhid(what, _by_what) -> void:
	if what is Set:
		unhide_set(what)
		
func _on_sth_unlocked(what, _by_what) -> void:
	if what is Set:
		unlock_set(what)
		
