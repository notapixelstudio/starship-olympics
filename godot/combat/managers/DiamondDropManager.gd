extends Node

export var diamond_scene : PackedScene
export var max_drops := 4

func _ready():
	Events.connect('ship_died', self, '_on_ship_died')
	
func _on_ship_died(ship, killer, for_good):
	# spawn a diamond where the ship has died
	var diamond = diamond_scene.instance()
	ship.get_parent().add_child(diamond)
	diamond.global_position = ship.global_position
	diamond.linear_velocity = ship.linear_velocity
	
	for i in range(max_drops):
		var coin = diamond_scene.instance()
		$Battlefield.add_child(coin)
		coin.position = dropper.position
		coin.linear_velocity = dropper.linear_velocity + Vector2(500,0).rotated(randi()/8/PI)
