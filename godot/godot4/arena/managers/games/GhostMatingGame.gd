extends Node

var _follows := {}

func _ready():
	Events.match_over.connect(_on_match_over)
	Events.ghost_touched.connect(_on_ghost_touched)
	Events.ghosts_matched.connect(_on_ghosts_matched)
	
func _on_ghost_touched(ghost:Ghost, ship:Ship):
	# each ship is followed by a single ghost max
	if _follows.has(ship):
		return
		
	# each ghost follows a single ship max
	if not ghost.is_roaming_free():
		return
		
	ghost.follow(ship)
	_follows.set(ship, ghost)
	
func _on_ghosts_matched(ghost_1:Ghost, ghost_2:Ghost):
	# find players, if any
	var scoring_ships = []
	var ship_1 = _follows.find_key(ghost_1)
	if ship_1 != null:
		scoring_ships.append(ship_1)
	var ship_2 = _follows.find_key(ghost_2)
	if ship_2 != null:
		scoring_ships.append(ship_2)
		
	for ship in scoring_ships:
		# assign points
		Events.points_scored.emit(2, ship.get_team())
		
		# show feedback
		Events.message.emit(2, ship.get_color(), ship.global_position)
		
		_follows.erase(ship)
		
	# clear ghosts
	ghost_1.queue_free()
	ghost_2.queue_free()
	
func _on_match_over(data:Dictionary) -> void:
	if Events.ghost_touched.is_connected(_on_ghost_touched):
		Events.ghost_touched.disconnect(_on_ghost_touched)
		
	if Events.ghosts_matched.is_connected(_on_ghosts_matched):
		Events.ghosts_matched.disconnect(_on_ghosts_matched)
