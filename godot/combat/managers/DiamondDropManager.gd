extends Node

export var diamond_scene : PackedScene
export var max_drops := 3

func _ready():
	Events.connect('ship_died', self, '_on_ship_died')
	
func _on_ship_died(ship, killer, for_good):
	# subtract loot from player's score
	var score = global.the_match.get_score(ship.get_player().get_id())
	var how_many_drops = min(score, max_drops)
	global.the_match.add_score_to_team(ship.get_team(), -how_many_drops)

	# spawn diamonds where the ship has died
	for i in range(how_many_drops):
		var diamond = diamond_scene.instance()
		diamond.appear = false
		ship.get_parent().add_child(diamond)
		diamond.global_position = ship.global_position
		diamond.linear_velocity = ship.linear_velocity + Vector2(500,0).rotated(randi()/8/PI)
		# flash diamonds
		diamond.damage(null, killer)
