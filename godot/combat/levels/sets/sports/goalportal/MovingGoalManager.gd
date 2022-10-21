extends Node

var defending_side := "right"
var last_ship_with_ball = null

func _ready():
	$"%LeftGoalPortalGate".disable()
	$"%LeftZone".disable()
	Events.connect("holdable_loaded", self, '_on_holdable_loaded')
	Events.connect("holdable_swapped", self, '_on_holdable_swapped')
	
func _on_holdable_loaded(holdable, ship):
	if ship != last_ship_with_ball:
		if last_ship_with_ball != null:
			toggle_goals(ship.global_position)
		last_ship_with_ball = ship
		
func _on_holdable_swapped(holdable1, holdable2, ship1, ship2):
	if holdable1 and holdable1 is Ball:
		last_ship_with_ball = ship1
	elif holdable2 and holdable2 is Ball:
		last_ship_with_ball = ship2
	toggle_goals(last_ship_with_ball.global_position)
	
func toggle_goals(where) -> void:
	if defending_side == 'right' and where.x > 0:
		defending_side = 'left'
		$"%LeftGoalPortalGate".enable()
		$"%RightGoalPortalGate".disable()
		$"%LeftZone".enable()
		$"%RightZone".disable()
	elif defending_side == 'left' and where.x <= 0:
		defending_side = 'right'
		$"%LeftGoalPortalGate".disable()
		$"%RightGoalPortalGate".enable()
		$"%LeftZone".disable()
		$"%RightZone".enable()
		
