extends Node

const WAVES_GROUP = "spawn_waves"
const COLLECTABLE = "coin"
const WAVE_DELAY = 2
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
	
	Events.connect("sth_collected", self, "_on_sth_collected")
	# First spawner should already be in the field
	setup(get_tree().get_nodes_in_group(WAVES_GROUP))
	var spawner: GroupSpawner = self.get_spawner(spawners_per_wave[current_wave])
	Events.emit_signal("ask_to_spawn", spawner, 0)
	
func get_spawner(spawners: Array) -> GroupSpawner:
	var next_spawner = spawners.pop_back()
	return next_spawner
	
func setup(spawners, starting_wave = 0):
	current_wave = starting_wave
	spawners_per_wave = {}
	for s in spawners:
		if s.wave_number >= current_wave:
			spawners_per_wave[s.wave_number] = s.get_spawners()
			spawners_per_wave[s.wave_number].shuffle()
	

func intro():
	yield(get_tree().create_timer(1), "timeout")
	wave_timer.start()
	emit_signal("done")

func spawned(element_spawned: GroupSpawner):
	print("This just spawned {spawned_element}".format({"spawned_element": element_spawned}))
	elements_spawned += element_spawned.get_child_count()
	
func _handle_waves():
	if not len(spawners_per_wave[current_wave]): # or elements_spawned>=min_elements_per_wave: @ TODO: check this condition, if it is still valid
		current_wave += 1
		elements_spawned = 0
	if current_wave >= len(spawners_per_wave):
		current_wave -= 1
		setup(get_tree().get_nodes_in_group(WAVES_GROUP), current_wave)
		
	var spawner: GroupSpawner = self.get_spawner(spawners_per_wave[current_wave])
	Events.emit_signal("ask_to_spawn", spawner, WAVE_DELAY)
	self.reset_wave_timer()
	
func reset_wave_timer():
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
	
