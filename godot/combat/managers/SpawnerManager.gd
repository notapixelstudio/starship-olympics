extends Node

const WAVES_GROUP = "spawn_waves"
const COLLECTABLE = "coin"
const WAVE_DELAY = 0.0
const BASE_TIME = 2.5
var to_next_wave = 2
var current_wave = 0

var waves : Dictionary = {}

signal spawn_next
var spawners_per_wave : Dictionary
var how_many_spawners: int
var current_spawners = 0

onready var wave_timer = $Timer
signal done

func _ready():
	Events.connect("spawned", self, "spawned")
	
	Events.connect("sth_collected", self, "_on_sth_collected")
	# First spawner should already be in the field
	# WARNING wait for variants to settle
	yield(get_tree(), "idle_frame")
	setup(get_tree().get_nodes_in_group(WAVES_GROUP))
	
func get_spawner(spawners: Array) -> ElementSpawnerGroup:
	var next_spawner = spawners.pop_back()
	return next_spawner
	
func setup(wave_nodes, starting_wave = 0):
	current_wave = starting_wave
	spawners_per_wave = {}
	for wave_node in wave_nodes:
		var number = wave_node.wave_number
		if number >= current_wave:
			spawners_per_wave[number] = wave_node.get_spawners()
			spawners_per_wave[number].shuffle()
		
		waves[number] = wave_node
	
func start():
	wave_timer.start()
	
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
		setup(get_tree().get_nodes_in_group(WAVES_GROUP), current_wave)
		
	var spawner: ElementSpawnerGroup = self.get_spawner(spawners_per_wave[current_wave])
	Events.emit_signal("ask_to_spawn", spawner, WAVE_DELAY + waves[current_wave].extra_delay)
	waves[current_wave].times_spawned += 1
	wave_timer.wait_time = BASE_TIME + WAVE_DELAY + waves[current_wave].extra_delay
	self.reset_wave_timer()
	
func reset_wave_timer():
	wave_timer.stop()
	wave_timer.start()
	
func _on_Timer_timeout():
	print("asking to spawn because timer of {timer_wait_time} has expired".format({"timer_wait_time": wave_timer.wait_time}))
	_handle_waves()

func _on_sth_collected(_collector, collectee):
	# if there are no collectables to be collected anymore. We can move on with spawning
	var all = len(get_tree().get_nodes_in_group(COLLECTABLE))
	if all == 1:
		print("asking to spawn because there are no collectable anymore")
		_handle_waves()
	
