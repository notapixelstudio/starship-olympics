@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("AutoSignals", "Node", preload("AutoSignals.gd"), preload("icons/AutoSignals.svg"))
	

func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("AutoSignals")
	
