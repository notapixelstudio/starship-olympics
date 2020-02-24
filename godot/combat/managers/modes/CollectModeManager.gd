extends ModeManager

const COINGROUP = "coin"
const MULTIPLIER = 2
const WAVE_DELAY = 4
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
	wave_timer.start()
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
	if not enabled:
		return
		
	if collectee is Diamond:
		var score = score_multiplier*collectee.points
		emit_signal('score', collector.get_id(), score)
		emit_signal('show_score', collector.species, score, collectee.global_position)
		
func _on_coins_dropped(dropper, amount):
	emit_signal('score', dropper.get_id(), -score_multiplier * amount)

var wave_ready = false 
func _process(delta):
	if wave_ready and (not get_tree().get_nodes_in_group(COINGROUP) or wave_timer.time_left <= 0.01):
		wave_ready = false
		_handle_waves()
		
func _handle_waves():
	
	if not len(spawners_per_wave[current_wave]) or elements_spawned>=min_elements_per_wave:
		current_wave += 1
		elements_spawned = 0
	if current_wave >= max_waves:
		initialize(spawners, WAVE_DELAY, current_wave - 1)
		return
	spawners_per_wave[current_wave].shuffle()
	var next_spawner = (spawners_per_wave[current_wave] as Array).pop_back()
	elements_spawned += 1
	emit_signal('spawn_next', next_spawner, WAVE_DELAY)
		
func reset_wave_timer():
	wave_timer.start()
	
func on_wave_ready():
	wave_ready = true
	reset_wave_timer()
	
