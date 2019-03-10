tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("GShape", "Node", preload("GShape.gd"), preload("icons/GShape.svg"))
	add_custom_type("GConvexPolygon", "Node", preload("GConvexPolygon.gd"), preload("icons/GConvexPolygon.svg"))
	add_custom_type("GRect", "Node", preload("GRect.gd"), preload("icons/GRect.svg"))
	add_custom_type("GHexagon", "Node", preload("GHexagon.gd"), preload("icons/GHexagon.svg"))
	add_custom_type("GCircle", "Node", preload("GCircle.gd"), preload("icons/GCircle.svg"))
	add_custom_type("GBeveledRect", "Node", preload("GBeveledRect.gd"), preload("icons/GBeveledRect.svg"))
	add_custom_type("GSegment", "Node", preload("GSegment.gd"), preload("icons/GSegment.svg"))
	
func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("GShape")
	remove_custom_type("GConvexPolygon")
	remove_custom_type("GRect")
	remove_custom_type("GHexagon")
	remove_custom_type("GCircle")
	remove_custom_type("GBeveledRect")
	remove_custom_type("GSegment")
	