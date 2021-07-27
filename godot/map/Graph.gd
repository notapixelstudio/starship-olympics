extends Node

class_name Graph

## key: a MapLocation
## value: the MapLocation's neighbours (as a Dictionary with neighbours as keys)
var neighbours := {}

## register the connection between two given MapLocations
func add_path(from: MapLocation, to: MapLocation) -> void:
	if not neighbours.has(from):
		neighbours[from] = {}
		
	if not neighbours.has(to):
		neighbours[to] = {}
		
	neighbours[from][to] = true
	neighbours[to][from] = true
	
## return the MapLocation neighbours of the given MapLocation
func get_neighbours(loc: MapLocation) -> Array: # [MapLocation]
	assert(neighbours.has(loc))
	
	return neighbours[loc].keys()

func _to_string() -> String:
	# method override for 'print()'
	var result := ''
	for node in neighbours.keys():
		var n := []
		for k in neighbours[node].keys():
			n.append(k.get_id())
		result += node.get_id() + ' <-> '+str(n)+'\n'
	return result
	
