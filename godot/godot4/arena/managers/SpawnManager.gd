extends Node

@export var battlefield: Node2D

func _ready() -> void:
	Events.spawn_request.connect(_on_spawn_request)

func _on_spawn_request(object:Node) -> void:
	battlefield.add_child.call_deferred(object)
