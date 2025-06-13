extends Node
const E = 2.71828

###############################
##### FILE SYSTEM UTILS #######
###############################
const SPECIES_PATH = "res://selection/characters"


func dir_contents(path:String, starts_with:String = "", extension:String = ".tscn"):
	"""
	@param path:String given the path 
	@return a list of filename
	"""
	var list_files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(extension):
					if not starts_with or file_name.find(starts_with) == 0: 
						list_files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list_files

func mod(a,b):
	"""
	Modulus: Maybe fposmod and fmod will do the trick by its own
	"""
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret

func get_resources(base_path: String) -> Dictionary:
	var ret := {}
	var resources = dir_contents(base_path, "", ".tres")
	for filename in resources:
		var this_res = load(base_path.path_join(filename))
		var res_id = this_res.get_id()
		ret[res_id] = this_res
	return ret

func end_execution():
	# trigger quit
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	
func sigmoid(x, width):
	return 1-1/(1+pow(E, -10*(x/width-0.5)))
