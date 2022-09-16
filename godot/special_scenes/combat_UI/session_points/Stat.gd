extends VBoxContainer
@tool

@export var key: String :
	get:
		return key # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_key
@export var stats_value: String= str(0) :
	get:
		return stats_value # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_stats_value

func set_stats_value(value: String):
	stats_value = value
	$Value.text = stats_value
	
func set_key(value: String):
	key = value
	$Key.text = key
	
