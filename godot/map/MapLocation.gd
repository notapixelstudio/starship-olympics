extends MapCell

class_name MapLocation



var paths_to : Dictionary = {} # {MapLocation: [MapPath] }

func get_id() -> String:
	return self.name
	
func add_path(path):
	paths_to[path.to] = path
	
func get_element_to_unlock():
	var to_be_unlocked = []
	for map_loc in paths_to:
		var loc_id : String = map_loc.get_id()
		if TheUnlocker.get_status_location(loc_id):
			to_be_unlocked.append(map_loc)
	if to_be_unlocked:
		var index = randi() % len(to_be_unlocked)
		return paths_to.keys()[index]
	return null

func unlock():
	pass
