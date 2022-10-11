extends Node

var last_sides := {}

func _ready():
	Events.connect("holdable_loaded", self, '_on_holdable_loaded')
	Events.connect("holdable_swapped", self, '_on_holdable_swapped')

func _on_LeftNoHolderZone_entered(zone, body):
	check_side('left', body)

func _on_RightNoHolderZone_entered(zone, body):
	check_side('right', body)
	
func check_side(side, body):
	if body is Ship and not body.has_cargo():
		if last_sides.has(body.get_id()) and last_sides[body.get_id()] != side:
			var player = body.get_player()
			global.the_match.add_score(player.get_id(), 1)
			global.arena.show_msg(player.species, 1, body.position)
		last_sides[body.get_id()] = side

func _on_holdable_loaded(holdable, ship):
	last_sides[ship.get_id()] = 'any'
	
func _on_holdable_swapped(holdable1, holdable2, ship1, ship2):
	last_sides[ship1.get_id()] = 'any'
	last_sides[ship2.get_id()] = 'any'
