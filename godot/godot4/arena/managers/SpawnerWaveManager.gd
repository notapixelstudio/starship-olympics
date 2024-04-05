extends Node

@export var base_time := 2.5
@export var waves : Array[SpawnerWave]
@export var battlefield: Node2D

const WAVES_GROUP = "spawn_waves"
const COLLECTABLE = "coin"
const WAVE_DELAY = 0.0
var to_next_wave = 2
var current_wave = 0


signal spawn_next
var spawners_per_wave : Dictionary
var how_many_spawners: int
var current_spawners = 0

signal done

func _ready():
	Events.connect("spawned", Callable(self, "spawned"))
	
	Events.connect("sth_collected", Callable(self, "_on_sth_collected"))
	
	setup()
	
	
func setup(starting_wave = 0):
	current_wave = starting_wave
	spawners_per_wave = {}
	for i in range(len(waves)):
		var wave = waves[i]
		if i >= current_wave:
			spawners_per_wave[i] = wave.get_spawners()
			spawners_per_wave[i].shuffle()
	
func start():
	%Timer.start()
	
func spawned(element_spawned: ElementSpawnerGroup):
	print("This just spawned {spawned_element}".format({"spawned_element": element_spawned}))
	
	
func _handle_waves():
	var no_spawners_left : bool = len(spawners_per_wave[current_wave]) == 0
	var max_repeats_reached : bool = waves[current_wave].max_repeats != -1 and waves[current_wave].times_spawned >= waves[current_wave].max_repeats
	if no_spawners_left or max_repeats_reached:
		current_wave += 1
	var last_wave : bool = current_wave >= len(spawners_per_wave)
	if last_wave:
		current_wave -= 1 # keep spawning the last wave
		setup(current_wave)
		
	var spawner: ElementSpawnerGroup = spawners_per_wave[current_wave].pop_back()
	#Events.emit_signal("ask_to_spawn", spawner, WAVE_DELAY + waves[current_wave].extra_delay)
	spawner.spawn(battlefield)
	waves[current_wave].times_spawned += 1
	%Timer.wait_time = base_time + WAVE_DELAY + waves[current_wave].extra_delay
	self.reset_wave_timer()
	
func reset_wave_timer():
	%Timer.stop()
	%Timer.start()
	
func _on_Timer_timeout():
	print("asking to spawn because timer of {timer_wait_time} has expired".format({"timer_wait_time": %Timer.wait_time}))
	_handle_waves()

func _on_sth_collected(_collector, collectee):
	# if there are no collectables to be collected anymore. We can move on with spawning
	var all = len(get_tree().get_nodes_in_group(COLLECTABLE))
	if all == 1:
		print("asking to spawn because there are no collectable anymore")
		_handle_waves()
	
