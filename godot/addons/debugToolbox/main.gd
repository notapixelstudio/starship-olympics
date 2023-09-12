@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("DebugNode", "Node", preload("DebugNode.gd"), preload("icons/DebugNode.svg"))
	add_custom_type("FPSCounter", "Node2D", preload("FPSCounter.gd"), preload("icons/FPSCounter.svg"))
	add_custom_type("TestGrid", "Node2D", preload("TestGrid.gd"), preload("icons/TestGrid.svg"))
	
func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("DebugNode")
	remove_custom_type("FPSCounter")
	remove_custom_type("TestGrid")
