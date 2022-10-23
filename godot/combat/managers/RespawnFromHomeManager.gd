extends Node

export var future_spawners_path : NodePath

func _ready():
	global.arena.connect('all_ships_spawned', self, '_on_all_ships_spawned')

func _on_all_ships_spawned(spawners):
	var future_spawners = get_node(future_spawners_path)
	
	for spawner in spawners:
		if future_spawners != null:
			# move spawners to the designated points
			spawner.global_position = future_spawners.get_node(spawner.name).global_position
			spawner.global_rotation = future_spawners.get_node(spawner.name).global_rotation
		else:
			# move spawners to the center
			spawner.global_position = Vector2(0,0)
			spawner.global_rotation = -PI/2
