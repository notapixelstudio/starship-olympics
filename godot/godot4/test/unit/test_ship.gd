extends GutTest

@export var test_ship_scene = preload("res://godot4/actors/ships/Ship.tscn")

func before_all():
	gut.p('Example print')

func test_ship_has_brain_after_ready():
	var d = double(test_ship_scene, DOUBLE_STRATEGY.INCLUDE_NATIVE).instantiate()
	var b = d.get_node('Brain')
	d.get_name()
	assert_called_count(d.get_name, 1)
	assert_null(b)
	assert_engine_error("Node not found")
