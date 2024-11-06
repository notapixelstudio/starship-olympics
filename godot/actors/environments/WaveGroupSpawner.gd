extends Node2D

class_name SpawnerWave


@export var max_repeats := -1
@export var extra_delay := 0.0

var times_spawned := 0

func get_spawners() -> Array:
	return get_children()
