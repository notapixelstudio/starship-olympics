@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("Trait", "Node", preload("Trait.gd"), preload("icons/Trait.svg"))
	add_custom_type("Trait2D", "Node2D", preload("Trait2D.gd"), preload("icons/Trait2D.svg"))
	add_custom_type("Trait3D", "Node3D", preload("Trait3D.gd"), preload("icons/Trait3D.svg"))
	add_custom_type("TraitControl", "Control", preload("TraitControl.gd"), preload("icons/TraitControl.svg"))
	
	add_autoload_singleton("traits", "res://addons/traits/traits.gd")

func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("Trait")
	remove_custom_type("Trait2D")
	remove_custom_type("Trait3D")
	remove_custom_type("TraitControl")
	
	remove_autoload_singleton("traits")
	
