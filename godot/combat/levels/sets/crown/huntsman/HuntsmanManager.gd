extends Node

func _ready():
	Events.connect('ship_damaged', self, '_on_ship_damaged')
	
func _on_ship_damaged(ship, hazard, damager):
	if not damager:
		return
		
	var holdable = damager.get_cargo().get_holdable()
	if holdable != null and holdable is Ball and holdable.type == 'crown':
		global.the_match.add_score_to_team(damager.get_player().team, +1)
