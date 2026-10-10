extends Node

@export var respawn_from_home_timeout := 1.0

var _player_homes : Dictionary[Player,Home] = {}

func set_player_home(player:Player, home:Home) -> void:
	_player_homes[player] = home
	
func _ready() -> void:
	%AutoSignals \
		.bind(%ArenaScope.ship_died, _on_ship_died)
		
func _on_ship_died(player:Player) -> void:
	await get_tree().create_timer(respawn_from_home_timeout).timeout
	respawn_ship_from_home(player)
	
func respawn_ship_from_home(player:Player) -> void:
	var home = _player_homes[player]
	var ship = %ShipFactory.create(player, true) # create enabled ships
	ship.global_rotation = home.global_rotation
	ship.global_position = home.global_position
	%Battlefield.add_child(ship)
