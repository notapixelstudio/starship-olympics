extends Node

export var needs_water := false
export var dive_in_bonus := 0.5
export var underwater_pick_bonus := 0.5

func _ready():
	Events.connect("ship_dive_in", self, '_on_ship_dive_in')
	Events.connect("holdable_loaded", self, '_on_holdable_loaded')

func _process(delta):
	for player in global.the_game.get_players():
		if global.arena.player_has_valid_ship(player):
			var ship : Ship = global.arena.get_ship_from_player(player)
			
			var holdable = ship.get_cargo().get_holdable()
			
			if holdable != null and holdable is Ball:
				if holdable.type == 'crown':
					global.the_match.add_score_to_team(player.team, delta)
				elif holdable.type == 'sea_crown' and ship.is_really_diving():
					global.the_match.add_score_to_team(player.team, delta)
				elif holdable.type == 'negacrown':
					global.the_match.add_score_to_team(player.team, -delta)

func _on_ship_dive_in(ship):
	if ship.is_really_diving():
		var holdable = ship.get_cargo().get_holdable()
			
		if holdable != null and holdable is Ball and holdable.type == 'sea_crown':
			global.the_match.add_score_to_team(ship.get_team(), dive_in_bonus)

func _on_holdable_loaded(holdable, ship):
	if holdable.type == 'sea_crown' and ship.is_really_diving():
		global.the_match.add_score_to_team(ship.get_team(), underwater_pick_bonus)
		
