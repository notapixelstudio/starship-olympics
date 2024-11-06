@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	add_custom_type("VCustomShape", "Path2D", preload("VCustomShape.gd"), preload("icons/VCustomShape.svg"))
	add_custom_type("VRect", "Node", preload("VRect.gd"), preload("icons/VRect.svg"))
	add_custom_type("VRegularPolygon", "Node", preload("VRegularPolygon.gd"), preload("icons/VRegularPolygon.svg"))
	add_custom_type("VCircle", "Node", preload("VCircle.gd"), preload("icons/VCircle.svg"))
	add_custom_type("VEllipse", "Node", preload("VEllipse.gd"), preload("icons/VEllipse.svg"))
	add_custom_type("VBeveledRect", "Node", preload("VBeveledRect.gd"), preload("icons/VBeveledRect.svg"))
	add_custom_type("VMultiBeveledRect", "Node", preload("VMultiBeveledRect.gd"), preload("icons/VMultiBeveledRect.svg"))
	add_custom_type("VRoundedRect", "Node", preload("VRoundedRect.gd"), preload("icons/VRoundedRect.svg"))
	add_custom_type("VMultiRoundedRect", "Node", preload("VMultiRoundedRect.gd"), preload("icons/VMultiRoundedRect.svg"))
	
func _exit_tree():
	# Clean-up of the plugin goes here
	remove_custom_type("VCustomShape")
	remove_custom_type("VRect")
	remove_custom_type("VRegularPolygon")
	remove_custom_type("VCircle")
	remove_custom_type("VEllipse")
	remove_custom_type("VBeveledRect")
	remove_custom_type("VMultiBeveledRect")
	remove_custom_type("VRoundedRect")
	remove_custom_type("VMultiRoundedRect")
	
