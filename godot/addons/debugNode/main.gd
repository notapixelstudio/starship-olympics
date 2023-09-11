@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("DebugNode", "Node", preload("DebugNode.gd"), preload("icons/DebugNode.svg"))
	
func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("DebugNode")
