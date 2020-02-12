extends HBoxContainer
tool

export var key: String setget set_key
export var stats_value: String= str(0) setget set_stats  

onready var key_label = $Key
onready var value_label = $Value

func set_stats(value: String):
	stats_value = value
	refresh()
	
func set_key(value: String):
	key = value
	refresh()
	
func refresh():
	if not is_inside_tree():
		yield(self, "ready")
		
	$Key.text = key
	$Value.text = stats_value
