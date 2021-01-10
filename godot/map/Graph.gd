extends Node

class_name Graph

var graph = {}

func add_path(path):
	graph[path] = [path.from, path.to]
	

func get_map_path(from: MapCell, to:MapCell) -> MapPath:
	for path in graph:
		var elements = graph[path]
		if from in elements and to in elements:
			return path
	return null
	
func _to_string() -> String:
	# Method Override for `print()`
	var ret = {}
	for path in graph:
		var from : MapCell = graph[path][0]
		var to: MapCell = graph[path][1]
		ret[path.name] = {"from": from.get_id(), "to": to.get_id()}
	return str(ret)
