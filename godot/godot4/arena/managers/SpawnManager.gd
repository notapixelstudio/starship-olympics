extends Node

@export var battlefield: Node2D

func _ready() -> void:
	Events.spawn_request.connect(_on_spawn_request)

func _on_spawn_request(object:Node, callback:Callable=func(o):) -> void:
	var spawn = func():
		battlefield.add_child(object)
		callback.call(object)
	
	spawn.call_deferred()
	
