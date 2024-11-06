extends GutTest

@export var test_ship_scene = preload("res://godot4/actors/ships/Ship.tscn")

func before_all():
	gut.p('Example print')
	
func test_ship_has_brain_after_ready():
	var d = double(test_ship_scene).instantiate()
	var b = d.get_node('Brain')
	d.get_name()
	assert_call_count(d, 'get_name', 1)
	assert_null(b)
