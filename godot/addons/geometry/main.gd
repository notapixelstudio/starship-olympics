tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("GShape", "Resource", preload("GShape.gd"), preload("icons/GShape.svg"))
	add_custom_type("GPolygon", "Resource", preload("GPolygon.gd"), preload("icons/GShape.svg"))
	add_custom_type("GRect", "Resource", preload("GRect.gd"), preload("icons/GShape.svg"))
	

func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("GShape")
	remove_custom_type("GPolygon")
	remove_custom_type("GRect")
	