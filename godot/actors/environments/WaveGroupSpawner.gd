extends Node2D

class_name WaveGroupSpawner


export var wave_number = 0

func get_spawners() -> Array:
	return get_children()
