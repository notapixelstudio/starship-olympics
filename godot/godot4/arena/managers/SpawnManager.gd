extends Node

@export var battlefield: Node2D

func _ready() -> void:
	%AutoSignals \
		.bind(ArenaScope.get_scope(self).spawn_request, _on_spawn_request)
	
func _on_spawn_request(object:Node, callback:Callable=func(o):return) -> void:
	var spawn = func():
		battlefield.add_child(object)
		callback.call(object)
	
	spawn.call_deferred()
	
