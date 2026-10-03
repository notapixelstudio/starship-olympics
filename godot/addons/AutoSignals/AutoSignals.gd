class_name AutoSignals extends Node

var _bindings: Array[Array] = [] # Array[Array[Signal, Callable]]

## Binds a signal to a callable (method, lambda, or bound callable).
func bind(sig: Signal, callable: Callable) -> AutoSignals:
	_bindings.append([sig, callable])
	
	# if added while already inside tree, connect immediately
	if is_inside_tree():
		_connect_binding(sig, callable)
		
	return self # chaining

func _enter_tree() -> void:
	for binding in _bindings:
		var sig: Signal = binding[0]
		var callable: Callable = binding[1]
		_connect_binding(sig, callable)

func _exit_tree() -> void:
	for binding in _bindings:
		var sig: Signal = binding[0]
		var callable: Callable = binding[1]
		_disconnect_binding(sig, callable)

func _connect_binding(sig: Signal, callable: Callable) -> void:
	if not sig.get_object() or not is_instance_valid(sig.get_object()):
		return
	if not callable.is_valid():
		return
		
	if not sig.is_connected(callable):
		sig.connect(callable)

func _disconnect_binding(sig: Signal, callable: Callable) -> void:
	if not sig.get_object() or not is_instance_valid(sig.get_object()):
		return
		
	if sig.is_connected(callable):
		sig.disconnect(callable)

func clear() -> void:
	_exit_tree()
	_bindings.clear()
