@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("VCustomShape", "Path2D", preload("VCustomShape.gd"), preload("icons/VCustomShape.svg"))
	#add_custom_type("GRect", "Node", preload("GRect.gd"), preload("icons/GRect.svg"))
	add_custom_type("VRegularPolygon", "Node", preload("VRegularPolygon.gd"), preload("icons/VRegularPolygon.svg"))
	#add_custom_type("GCircle", "Node", preload("GCircle.gd"), preload("icons/GCircle.svg"))
	#add_custom_type("GEllipse", "Node", preload("GEllipse.gd"), preload("icons/GCircle.svg"))
	add_custom_type("VBeveledRect", "Node", preload("VBeveledRect.gd"), preload("icons/VBeveledRect.svg"))
	add_custom_type("VMultiBeveledRect", "Node", preload("VMultiBeveledRect.gd"), preload("icons/VMultiBeveledRect.svg"))
	#add_custom_type("GSegment", "Node", preload("GSegment.gd"), preload("icons/GSegment.svg"))
	add_custom_type("VRoundedRect", "Node", preload("VRoundedRect.gd"), preload("icons/VRoundedRect.svg"))
	
func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("VCustomShape")
	#remove_custom_type("GRect")
	remove_custom_type("VRegularPolygon")
	#remove_custom_type("GCircle")
	#remove_custom_type("GEllipse")
	remove_custom_type("VBeveledRect")
	remove_custom_type("VMultiBeveledRect")
	#remove_custom_type("GSegment")
	remove_custom_type("VRoundedRect")
	
