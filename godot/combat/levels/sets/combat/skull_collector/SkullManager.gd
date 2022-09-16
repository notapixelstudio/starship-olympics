extends Node

@export var skull_scene : PackedScene
@export var future_spawners_path : NodePath

func _ready():
	Events.connect('ship_died',Callable(self,'_on_ship_died'))
	global.arena.connect('all_ships_spawned',Callable(self,'_on_all_ships_spawned'))
	
func _on_ship_died(ship, killer, for_good):
	if killer == null or ship == killer:
		return
		
	# spawn a skull where the ship has died
	var skull = skull_scene.instantiate()
	ship.get_parent().add_child(skull)
	skull.global_position = ship.global_position
	skull.linear_velocity = ship.linear_velocity

func _on_all_ships_spawned(spawners):
	# move spawners to the center
	var future_spawners = get_node(future_spawners_path)
	
	for spawner in spawners:
		spawner.global_position = future_spawners.get_node(spawner.name).global_position
