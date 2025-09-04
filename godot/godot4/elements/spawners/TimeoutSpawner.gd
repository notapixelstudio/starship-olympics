extends Node2D

@export var element_scene : PackedScene
@export var starting_delay := 0.0
@export var wait_time := 1.0
@export var autostart := true
@export var max_elements := 1

@onready var timer = %Timer

var element_count := 0

func _ready() -> void:
	timer.wait_time = wait_time + starting_delay

func start() -> void:
	if autostart:
		timer.start()

func spawn() -> void:
	if element_count >= max_elements:
		return
		
	var element = element_scene.instantiate()
	element.tree_exiting.connect(_on_element_tree_exiting)
	element.global_position = global_position
	Events.spawn_request.emit(element)
	element_count += 1

func _on_element_tree_exiting() -> void:
	element_count -= 1
	timer.start(wait_time)
	
func _on_timer_timeout() -> void:
	spawn()
