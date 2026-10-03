extends Node

@export var battlefield: Node2D

func _ready() -> void:
	%AutoSignals \
		.bind(Events.spawn_request, _on_spawn_request) \
		.bind(Events.ship_spawn_request, _on_ship_spawn_request)
	
func _on_spawn_request(object:Node, callback:Callable=func(o):return) -> void:
	var spawn = func():
		battlefield.add_child(object)
		callback.call(object)
	
	spawn.call_deferred()
	
func _on_ship_spawn_request(player: Player) -> void:
	pass
