extends Node

export var skull_scene : PackedScene

func _ready():
	Events.connect('ship_died', self, '_on_ship_died')
	global.arena.connect('all_ships_spawned', self, '_on_all_ships_spawned')
	
func _on_ship_died(ship, killer, for_good):
	if killer == null or ship == killer:
		return
		
	# spawn a skull where the ship has died
	var skull = skull_scene.instance()
	ship.get_parent().add_child(skull)
	skull.global_position = ship.global_position
	skull.linear_velocity = ship.linear_velocity

func _on_all_ships_spawned(spawners):
	# move spawners to the center
	for spawner in spawners:
		spawner.position = Vector2(0,0)
