extends Node

class_name Graph

## key: a MapLocation
## value: the MapLocation's neighbours (as a Dictionary with neighbours as keys)
var neighbours := {}

## register the connection between two given MapLocations, also storing the Path
func add_path(path, from: MapLocation, to: MapLocation) -> void:
	# can't check path with a type hint, caller couldn't assign the correct type
	
	if not neighbours.has(from):
		neighbours[from] = {}
		
	if not neighbours.has(to):
		neighbours[to] = {}
		
	neighbours[from][to] = path
	neighbours[to][from] = path
	
## return the MapLocation neighbours of the given MapLocation, along with their connecting Path
func get_neighbourhood(loc: MapLocation) -> Dictionary: # {MapLocation: Path}
	assert(neighbours.has(loc))
	return neighbours[loc]

func _to_string() -> String:
	# method override for 'print()'
	var result := ''
	for node in neighbours.keys():
		var n := []
		for k in neighbours[node].keys():
			n.append(k.get_id())
		result += node.get_id() + ' <-> '+str(n)+'\n'
	return result
	
