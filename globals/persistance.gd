extends Node

const SAVE_PATH ="user://savegame.save"
var _settings = {}

func save_game():
	var save_dict = {}
	# Get all the save data from persistent nodes
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		# The key to access each data dictionary is the node's path, so we can retrieve the node in load_game below
		# For this to work, the node path must not change! You can move the nodes up/down the hierarchy,
		# But if you give them a new parent, you'll have to update the save
		# E.g. if /root/Game/Player becomes /root/Game/Characters/YSort/Player
		save_dict[node.get_path()] = node.get_state()
	
	# Create a file
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.WRITE)
	print("We are going to save here: ", save_file.get_path_absolute(), " this JSON")
	print(save_dict)
	# Serialize the data dictionary to JSON
	save_file.store_line(to_json(save_dict))
	
	# Write the JSON to the file and save to disk
	save_file.close()

func load_game() -> bool:
	# When we load a file, we must check that it exists before we try to open it or it'll crash the game
	var save_file = File.new()
	if not save_file.file_exists(SAVE_PATH):
		print("The save file does not exist.")
		return false
	save_file.open(SAVE_PATH, File.READ)

	# parse file data - convert the JSON back to a dictionary
	var data = {}
	data = parse_json(save_file.get_as_text())

	# The dict keys on the first level are paths to the nodes
	for node_path in data.keys():
		# We get the node's path from the for loop, so we can use it to retrieve
		# Both the node to load (e.g. Player, Player2) and the node's data with data[node_path]
		var node_data = data[node_path]
		# We find the right node to load node_data into and call its load method
		get_node(node_path).load_state(node_data)
	save_file.close()
	return true