tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("Entity", "Node", preload("Entity.gd"), preload("icons/Entity.png"))
	add_custom_type("Component", "Node", preload("Component.gd"), preload("icons/Component.png"))
	add_custom_type("Manager", "Node", preload("Manager.gd"), preload("icons/Manager.png"))
	add_custom_type("Entity2D", "Node2D", preload("Entity.gd"), preload("icons/Entity2D.png"))
	add_custom_type("Component2D", "Node2D", preload("Component.gd"), preload("icons/Component2D.png"))
	add_custom_type("Entity3D", "Spatial", preload("Entity.gd"), preload("icons/Entity3D.png"))
	add_custom_type("Component3D", "Spatial", preload("Component.gd"), preload("icons/Component3D.png"))
	add_custom_type("EntityControl", "Control", preload("Entity.gd"), preload("icons/EntityControl.png"))
	add_custom_type("ComponentControl", "Control", preload("Component.gd"), preload("icons/ComponentControl.png"))
	
	
	add_autoload_singleton("ECM", "res://addons/ECM/ECM.gd")

func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("Entity")
	remove_custom_type("Component")
	remove_custom_type("Manager")
	remove_custom_type("Entity2D")
	remove_custom_type("Component2D")
	remove_custom_type("Entity3D")
	remove_custom_type("Component3D")
	remove_custom_type("EntityControl")
	remove_custom_type("ComponentControl")
	
	remove_autoload_singleton("ECM")
	