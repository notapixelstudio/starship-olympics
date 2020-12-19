tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("Trait", "Node", preload("Trait.gd"), preload("icons/Trait.svg"))
	
	add_autoload_singleton("traits", "res://addons/traits/traits.gd")

func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("Trait")
	
	remove_autoload_singleton("traits")
	
