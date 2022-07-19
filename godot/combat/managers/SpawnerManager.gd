extends Node

const COINGROUP = "coin"
const WAVE_DELAY = 3
var to_next_wave = 2
var current_wave = 0

signal spawn_next
var spawners: Array
var spawners_per_wave : Dictionary
var max_waves: int
var how_many_spawners: int
var current_spawners = 0

export var min_elements_per_wave = 3
var elements_spawned := 0
onready var wave_timer = $Timer
signal done

func initialize(_spawners, wait_time = 0, wave = 0):
	current_wave = wave
	spawners = _spawners
	how_many_spawners = len(spawners)
	spawners_per_wave = {}
	var waves = 0
	for s in spawners:
		if not s.wave in spawners_per_wave:
			spawners_per_wave[s.wave] = [s]
			waves += 1
		else:
			spawners_per_wave[s.wave].append(s)
			
	max_waves = waves
	spawners_per_wave[current_wave].shuffle()
	
	wave_timer.start()
	var next_spawner = spawners_per_wave[current_wave].pop_back()
	elements_spawned += 1
	global.arena.on_next_wave(next_spawner, wait_time)
	
func intro():
	global.arena.connect('wave_ready', self, 'on_wave_ready')
	self.initialize(get_tree().get_nodes_in_group("spawner_group"))
	yield(get_tree().create_timer(1), "timeout")
	emit_signal('done')
	
var wave_ready = false 
func _process(delta):
	if wave_ready and not get_tree().get_nodes_in_group(COINGROUP):
		_handle_waves()
		
func _handle_waves():
	wave_ready = false
	
	if not len(spawners_per_wave[current_wave]) or elements_spawned>=min_elements_per_wave:
		current_wave += 1
		elements_spawned = 0
	if current_wave >= max_waves:
		initialize(spawners, WAVE_DELAY, current_wave - 1)
		return
	spawners_per_wave[current_wave].shuffle()
	var next_spawner = (spawners_per_wave[current_wave] as Array).pop_back()
	elements_spawned += 1
	global.arena.on_next_wave(next_spawner, WAVE_DELAY)
	
func reset_wave_timer():
	wave_timer.start()
	
func on_wave_ready():
	wave_ready = true
	reset_wave_timer()
	
func _on_Timer_timeout():
	_handle_waves()
