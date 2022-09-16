extends Node

#const CameraEye = preload('res://utils/CameraEye.tscn')
const LAP_SCORE = 10

var ships = []
var lap_progress = {}
var laps = {}
#var eyes = {}
var race_path

func start():
	# register all ships
	for ship in get_tree().get_nodes_in_group('player_ship'):
		ships.append(ship)
		lap_progress[ship] = 0
		laps[ship] = 0
		
		# add a camera eye to anticipate each ship
		#var eye = CameraEye.instantiate()
		#eyes[ship] = eye
		#eye.position = ship.position
		#global.arena.battlefield.add_child(eye)
		
	# find the race path
	race_path = get_tree().get_nodes_in_group('race_path')[0]

func _process(delta):
	for ship in ships:
		if not is_instance_valid(ship):
			continue
		var curve_offset = race_path.curve.get_closest_offset(ship.global_position)
		var lap_length = race_path.curve.get_baked_length()
		
		var new_lap_progress = LAP_SCORE * curve_offset / lap_length
		
		if new_lap_progress - lap_progress[ship] < -0.9*LAP_SCORE:
			# add a lap if there's a sudden loss of progress
			laps[ship] += 1
			
		if new_lap_progress - lap_progress[ship] > 0.9*LAP_SCORE:
			# subtract a lap if there's a sudden gain of progress
			laps[ship] -= 1
			
		lap_progress[ship] = new_lap_progress
		
		global.the_match.set_score(ship.get_player().id, LAP_SCORE*laps[ship]+lap_progress[ship])
		
		# move camera eyes
		#eyes[ship].position = race_path.curve.interpolate_baked(fmod(curve_offset + 2000, lap_length))
		
