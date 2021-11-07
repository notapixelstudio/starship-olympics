extends Node

# status
const HIDDEN = "hidden"
const LOCKED = "locked"
const UNLOCKED = "unlocked"

export (String, "hidden", "locked", "unlocked") var status 

const PERSIST_GROUP = "persist_unlocking"
func _ready():
	add_to_group(PERSIST_GROUP)

var unlocked_elements = {
	"map_paths": {
		"Path5" : UNLOCKED,
		"Path6" : UNLOCKED,
		"Path7" : UNLOCKED,
	},
	"sets": {
		"core": UNLOCKED,
		"diamonds": HIDDEN,
		"ice": HIDDEN,
		"survival": HIDDEN,
		"casino": LOCKED,
		"snake": HIDDEN,
		"sports": LOCKED,
		"asteroids": HIDDEN,
		"conquest": HIDDEN,
		"death": LOCKED,
		"crown": HIDDEN,
		"cards": LOCKED,
	},
	"species": {
		"mantiacs_1": UNLOCKED,
		"robolords_1": UNLOCKED,
		"trixens_1": UNLOCKED,
		"umidorians_1": UNLOCKED,
		"pentagonions_1": UNLOCKED,
		"auriels_1": UNLOCKED,
		"eelectrons_1": UNLOCKED,
		"robolords_2": LOCKED,
		"trixens_2": LOCKED,
		"auriels_2": LOCKED,
		"umidorians_2": LOCKED,
		"mantiacs_2": LOCKED
	}
}

func get_unlocked_list(group_id: String, status: String = UNLOCKED) -> Array:
	var group_object = self.unlocked_elements.get(group_id)
	var list_unlocked = []
	if group_object :
		for element in group_object:
			if group_object[element] == status:
				list_unlocked.append(element)
	return list_unlocked
	
func get_status(group_id: String, element_id: String, default := LOCKED) -> String:
	var group_object = self.unlocked_elements.get(group_id)
	if group_object :
		return group_object.get(element_id, default)
	else:
		return default
		

func unlock_element(group_id: String, element_id: String, new_status=UNLOCKED) -> void:
	if group_id in self.unlocked_elements:
		self.unlocked_elements[group_id][element_id] = new_status
	else:
		self.unlocked_elements[group_id] = {element_id: new_status}
	persistance.save_group_to_file(PERSIST_GROUP)


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
		unlocked_elements = self.unlocked_elements
	}
