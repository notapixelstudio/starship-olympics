extends Node
class_name DebugNode

## A utility node that offers helper methods for debugging purposes. It self-destructs outside
## of a debug build.

## The host node to debug. If not set, it defaults to the parent node.
@export var host: Node : get = get_host

## Returns the current host this node is attached to.
func get_host() -> Node:
	assert(host != null)
	return host 

func _ready():
	# self-destroy if not debugging
	if not OS.is_debug_build():
		queue_free()
		
	# default host is parent
	if host == null:
		host = get_parent()

## Returns whether the host node has been run as a standalone scene.
func is_host_standalone() -> bool:
	return get_host().get_parent() == get_tree().root

## Place the host node inside a test chamber (useful when testing a scene in standalone mode).
func place_host_in_test_chamber(test_chamber : Node = null) -> void:
	# create default test chamber
	if test_chamber == null:
		test_chamber = Node2D.new()
		test_chamber.set_name('TestChamber')
		var camera = Camera2D.new()
		test_chamber.add_child(camera)
	get_host().get_parent().add_child.call_deferred(test_chamber)
	get_host().reparent.call_deferred(test_chamber)
	
