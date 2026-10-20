extends Node

var _royalnesses := {}

func _ready() -> void:
	%AutoSignals \
		.bind(Events.score, _on_score) \
		.bind(Events.match_over, _on_match_over)
	
func _on_score(amount, player:Player, global_position:Vector2) -> void:
	# assign points
	Events.points_scored.emit(float(amount), player.get_team())
	if global_position:
		Events.message.emit(amount, player.get_color(), global_position)

func _physics_process(delta: float) -> void:
	# assign points for keeping crowns
	for ship in get_tree().get_nodes_in_group('Ship'):
		if ship.has_cargo_class(Crown):
			if not ship in _royalnesses:
				_royalnesses[ship] = 0.0
				
			var points : float = delta * (ship.get_cargo() as Crown).points_per_second
			Events.points_scored.emit(points, ship.get_team())
			_royalnesses[ship] += points
			var msg = str("+%0.2f" % _royalnesses[ship])
			ship.set_message(msg)
			
		elif ship in _royalnesses:
			Events.message.emit(_royalnesses[ship], ship.get_color(), ship.global_position + Vector2(0,-150))
			_royalnesses.erase(ship)
			ship.set_message('')
			
func _on_match_over(data:Dictionary) -> void:
	set_physics_process(false)
