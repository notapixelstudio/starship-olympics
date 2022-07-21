extends Node

const WAVES_GROUP = "spawn_waves"
const WAVE_DELAY = 3
var to_next_wave = 2
var current_wave = 0

signal spawn_next
var spawners_per_wave : Dictionary
var how_many_spawners: int
var current_spawners = 0

export var min_elements_per_wave = 3
var elements_spawned := 0
onready var wave_timer = $Timer
signal done

func _ready():
	Events.connect("spawned", self, "spawned")

func setup(spawners, wait_time = 0, wave = 0):
	current_wave = wave
	spawners_per_wave = {}
	for s in spawners:
		spawners_per_wave[s.wave_number] = s.get_spawners()
	spawners_per_wave[current_wave].shuffle()
	wave_timer.start()
	var next_spawner = spawners_per_wave[current_wave].pop_back()
	return next_spawner

func intro():
	var spawner = setup(get_tree().get_nodes_in_group(WAVES_GROUP))
	Events.emit_signal("ask_to_spawn", spawner, 0)
	

func spawned(element_spawned: GroupSpawner):
	print("This just spawned {spawned_element}".format({"spawned_element": element_spawned}))
	if elements_spawned == 0:
		emit_signal("done")
	elements_spawned += 1
	
	
var wave_ready = false 

func _handle_waves():
	wave_ready = false
	
	if not len(spawners_per_wave[current_wave]) or elements_spawned>=min_elements_per_wave:
		current_wave += 1
		elements_spawned = 0
	if current_wave >= len(spawners_per_wave):
		setup(spawners_per_wave[current_wave], WAVE_DELAY, current_wave - 1)
		return
	spawners_per_wave[current_wave].shuffle()
	var next_spawner = (spawners_per_wave[current_wave] as Array).pop_back()
	Events.emit_signal("ask_to_spawn", next_spawner)
	
func reset_wave_timer():
	wave_timer.start()
	
func on_wave_ready():
	wave_ready = true
	reset_wave_timer()
	
func _on_Timer_timeout():
	_handle_waves()
