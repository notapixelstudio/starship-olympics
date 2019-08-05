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

export var min_elements_per_wave = 3
var elements_spawned := 0
onready var wave_timer = $Timer

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
	elements_spawned += 1
	emit_signal("spawn_next", next_spawner, wait_time)
	
func _on_sth_collected(collector, collectee):
	if collectee is Diamond:
		assert collector is Ship
		var score = score_multiplier*collectee.points
		emit_signal('score', collector.species, score)
		emit_signal('show_score', collector.species_template, score, collectee.global_position)
		
func _on_coins_dropped(dropper, amount):
	emit_signal('score', dropper.species, -score_multiplier*amount)

var wave_ready = true
func _process(delta):
	if wave_ready and (not get_tree().get_nodes_in_group(COINGROUP) or wave_timer.time_left <= 0):
		_handle_waves()
		
func _handle_waves():
	wave_ready = false
	if not len(spawners_per_wave[current_wave]) or elements_spawned>=min_elements_per_wave:
		current_wave += 1
		elements_spawned = 0
	if current_wave >= max_waves:
		initialize(spawners, 1.5, current_wave - 1)
		return
	spawners_per_wave[current_wave].shuffle()
	var next_spawner = (spawners_per_wave[current_wave] as Array).pop_back()
	elements_spawned += 1
	reset_wave_timer()
	emit_signal('spawn_next', next_spawner, 1)
		
func reset_wave_timer():
	wave_timer.start()
	
func on_wave_ready():
	wave_ready = true
	