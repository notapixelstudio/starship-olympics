extends Node

@export var base_time := 2.0
@export var spawn_on_all_collected := false
@export var spawn_on_timeout := true
@export var waves_container : Node2D
@export var battlefield: Node2D

const WAVES_GROUP = "spawn_waves"
const COLLECTABLE_GROUP = "Treasure"
const WAVE_DELAY = 0.0
var to_next_wave = 2
var current_wave = 0


signal spawn_next
var waves : Array
var spawners_per_wave : Dictionary
var how_many_spawners: int
var current_spawners = 0

signal done

func _ready():
	Events.match_over.connect(_on_match_over)
	
	Events.connect("spawned", spawned)
	
	waves = waves_container.get_children()
	
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
	if spawn_on_timeout:
		%Timer.start()
	if spawn_on_all_collected:
		%CheckEmptyTimer.start()
	
func spawned(element_spawned: ElementSpawnerGroup):
	print("This just spawned {spawned_element}".format({"spawned_element": element_spawned}))
	
	
func _handle_waves():
	while true: # keep looking for a non-empty, non zero repeats wave
		var over_last_wave : bool = current_wave >= len(spawners_per_wave)
		if over_last_wave:
			return
		#	current_wave -= 1 # keep spawning the last wave
		#	setup(current_wave)
		print('wave ', current_wave)
		var no_spawners_left : bool = len(spawners_per_wave[current_wave]) == 0
		var max_repeats_reached : bool = waves[current_wave].max_repeats != -1 and waves[current_wave].times_spawned >= waves[current_wave].max_repeats
		if no_spawners_left or max_repeats_reached:
			current_wave += 1
		else:
			break
	
	var over_last_wave : bool = current_wave >= len(spawners_per_wave)
	if over_last_wave:
		return
	#	current_wave -= 1 # keep spawning the last wave
	#	setup(current_wave)
	
	var spawner: ElementSpawnerGroup = spawners_per_wave[current_wave].pop_back()
	print('spawning from ', waves[current_wave].name)
	#Events.emit_signal("ask_to_spawn", spawner, WAVE_DELAY + waves[current_wave].extra_delay)
	spawner.spawn(battlefield)
	waves[current_wave].times_spawned += 1
	print('times spawned: ', waves[current_wave].times_spawned)
	
	var max_repeats_reached : bool = waves[current_wave].max_repeats != -1 and waves[current_wave].times_spawned >= waves[current_wave].max_repeats
	%Timer.stop()
	%Timer.wait_time = base_time + WAVE_DELAY + waves[min(current_wave+1,len(waves)-1) if max_repeats_reached else current_wave].extra_delay
	%Timer.start()
	
func _on_Timer_timeout():
	if not spawn_on_timeout:
		return
		
	print("asking to spawn because timer of {timer_wait_time} has expired".format({"timer_wait_time": %Timer.wait_time}))
	_handle_waves()

func _on_match_over(data:Dictionary) -> void:
	%Timer.stop()


func _on_check_empty_timer_timeout() -> void:
	if not spawn_on_all_collected:
		return
		
	# if there are no collectables to be collected anymore. We can move on with spawning
	var all = len(get_tree().get_nodes_in_group(COLLECTABLE_GROUP))
	if all <= 0:
		print("asking to spawn because there are no collectable anymore")
		_handle_waves()
