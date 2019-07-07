extends ModeManager

const COINGROUP = "coin"
const MULTIPLIER = 2
var to_next_wave = 2
var current_wave = 0

signal score
signal show_score
signal spawn_next
var spawners: Array
var spawners_per_wave : Dictionary
var max_waves: int
var how_many_spawners: int
var current_spawners = 0

func initialize(_spawners, wait_time = 0, wave = 0):
	current_wave = wave
	spawners = _spawners
	how_many_spawners = len(spawners)
	spawners_per_wave = {}
	var waves = 0
	for s in spawners:
		assert(s is CollectableSpawner)
		if not s.wave in spawners_per_wave:
			spawners_per_wave[s.wave] = [s]
			waves += 1
		else:
			spawners_per_wave[s.wave].append(s)
			
	max_waves = waves
	spawners_per_wave[current_wave].shuffle()
	var next_spawner = spawners_per_wave[current_wave].pop_back()
	emit_signal("spawn_next", next_spawner, wait_time)
	
func _on_sth_collected(collector, collectee):
	if collectee is Diamond:
		assert collector is Ship
		var score = score_multiplier*collectee.points
		emit_signal('score', collector.species, score)
		emit_signal('show_score', collector.species_template, score, collectee.global_position)
		var something_in = false
		yield(get_tree(), "idle_frame")
		if not get_tree().get_nodes_in_group(COINGROUP):
			if not len(spawners_per_wave[current_wave]):
				current_wave += 1
			if current_wave >= max_waves:
				initialize(spawners, 1.5, current_wave-1)
				return
			var next_spawner = (spawners_per_wave[current_wave] as Array).pop_back()
			spawners_per_wave[current_wave].shuffle()
			print(spawners_per_wave[current_wave])
			var animate_wall = false
			if current_wave == max_waves - 1:
				animate_wall = true
			emit_signal('spawn_next', next_spawner, 1, animate_wall) 
		
func _on_coins_dropped(dropper, amount):
	emit_signal('score', dropper.species, -score_multiplier*amount)
	