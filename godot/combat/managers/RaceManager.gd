extends Node

const LAP_SCORE = 10

var ships = []
var lap_progress = {}
var laps = {}
var race_path

func start():
	# register all ships
	for ship in get_tree().get_nodes_in_group('player_ship'):
		ships.append(ship)
		lap_progress[ship] = 0
		laps[ship] = 0
		
	# find the race path
	race_path = get_tree().get_nodes_in_group('race_path')[0]

func _process(delta):
	for ship in ships:
		var new_lap_progress = LAP_SCORE * race_path.curve.get_closest_offset(ship.global_position) / race_path.curve.get_baked_length()
		
		if new_lap_progress - lap_progress[ship] < -0.9*LAP_SCORE:
			# add a lap if there's a sudden loss of progress
			laps[ship] += 1
			
		if new_lap_progress - lap_progress[ship] > 0.9*LAP_SCORE:
			# subtract a lap if there's a sudden gain of progress
			laps[ship] -= 1
			
		lap_progress[ship] = new_lap_progress
		
		global.the_match.set_score(ship.get_player().id, LAP_SCORE*laps[ship]+lap_progress[ship])
		
