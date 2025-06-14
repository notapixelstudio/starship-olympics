extends Node

const SAVE_FILEPATH ="user://savegame.json"
const UNLOCK_FILEPATH ="user://unlocking.json"
const CONTROLS_FILEPATH ="user://controls.json"

var savegame_config := {
	# this config map contains as key the group_name and as value the filepath where to write 
	"persist": SAVE_FILEPATH,
	"persist_unlocking": UNLOCK_FILEPATH,
	"persist_controls": CONTROLS_FILEPATH
}

func _ready() -> void:
	Events.store_settings.connect(save_game)
	
	
func save_group_to_file(group_name: String):
	var filename = self.savegame_config[group_name]
	var save_nodes = get_tree().get_nodes_in_group(group_name)
	var save_dict = {}
	for node in save_nodes:
		# The key to access each data dictionary is the node's path, so we can retrieve the node in load_game below
		# For this to work, the node path must not change! You can move the nodes up/down the hierarchy,
		# But if you give them a new parent, you'll have to update the save
		# E.g. if /root/Game/Player becomes /root/Game/Characters/YSort/Player
		save_dict[node.get_path()] = node.get_state()
	
	# Create a file
	var save_file = FileAccess.open(filename, FileAccess.WRITE)
	print("We are going to save here: ", save_file.get_path_absolute(), " this JSON")
	# Serialize the data dictionary to JSON
	save_file.store_line(JSON.new().stringify(save_dict))
	
	# Write the JSON to the file and save to disk
	save_file.close()

func save_game():
	# Get all the save data from persistent nodes
	for group_name in self.savegame_config:
		save_group_to_file(group_name)
		

func get_saved_data(filepath: String = SAVE_FILEPATH) -> Dictionary:
		# When we load a file, we must check that it exists before we try to open it or it'll crash the game
		if not FileAccess.file_exists(filepath):
			print("The save file does not exist.")
			return {}
		var save_file = FileAccess.open(filepath, FileAccess.READ)
		print("We are going to load from this JSON: ", save_file.get_path_absolute())
		# parse file data - convert the JSON back to a dictionary
		var data = {}
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_file.get_as_text())
		data = test_json_conv.get_data()
		save_file.close()
		return data
	
	
func load_game() -> bool:
	for group_name in self.savegame_config:
		var filepath = self.savegame_config[group_name]
		print("We are going to load from this JSON for ", group_name, ": ", filepath)
		var data = get_saved_data(filepath)
		
		if not data:
			print("Not found any data for ", group_name, " in ", filepath)
			
		# The dict keys on the first level are paths to the nodes
		for node_path in data.keys():
			# We get the node's path from the for loop, so we can use it to retrieve
			# Both the node to load (e.g. Player, Player2) and the node's data with data[node_path]
			var node_data = data[node_path]
			# We find the right node to load node_data into and call its load method
			if get_node(node_path):
				get_node(node_path).load_state(node_data)
			else:
				printerr(node_path, " not found in the tree. Are you sure is it the right one?")
	return true
