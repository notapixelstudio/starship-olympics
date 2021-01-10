extends MapCell


class_name MapLocation

var paths_to : Dictionary = {} # {MapLocation: [MapPath] }

func get_id() -> String:
	return self.name
	
func add_path(path):
	paths_to[path.to] = path
	
func get_element_to_unlock():
	var index = randi() % len(paths_to)
	return paths_to.keys()[index]
