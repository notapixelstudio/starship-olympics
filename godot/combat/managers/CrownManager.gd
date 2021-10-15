extends Node

func _process(delta):
	for player in global.the_game.get_players():
		if global.arena.player_has_valid_ship(player):
			var ship : Ship = global.arena.get_ship_from_player(player)
			var holdable = ship.get_cargo().get_holdable()
			
			if holdable != null and holdable is Ball and holdable.type == 'crown':
				global.the_match.add_score(player.id, delta)
