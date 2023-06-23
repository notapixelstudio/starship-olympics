tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("StateMachine", "Node", preload("StateMachine.gd"), preload("icons/StateMachine.svg"))
	add_custom_type("State", "Node", preload("State.gd"), preload("icons/State.svg"))

func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("StateMachine")
	remove_custom_type("State")
	
