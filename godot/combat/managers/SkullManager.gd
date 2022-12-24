extends Node

export var skull_scene : PackedScene
export var future_spawners_path : NodePath

func _ready():
	Events.connect('ship_died', self, '_on_ship_died')
	
func _on_ship_died(ship, killer, for_good):
	# spawn a skull where the ship has died
	var skull = skull_scene.instance()
	ship.get_parent().add_child(skull)
	skull.global_position = ship.global_position
	skull.linear_velocity = ship.linear_velocity
