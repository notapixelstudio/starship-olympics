extends Node2D

@export var fruit_scene : PackedScene

func _ready():
	spawn(true)

func spawn(instantly:bool) -> void:
	var fruit = fruit_scene.instantiate()
	fruit.collected.connect(_on_fruit_collected)
	fruit.global_position = global_position
	Events.spawn_request.emit(fruit)
	if not instantly:
		fruit.disable_collisions()
		fruit.turn_small()
		fruit.grow()
		fruit.grown.connect(func(): fruit.enable_collisions())
	
func _on_fruit_collected(collector, fruit):
	if not $Timer.is_stopped():
		return
		
	$Timer.start()

func _on_timer_timeout():
	spawn(false)
