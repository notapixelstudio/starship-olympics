@tool
extends EditorPlugin

var dock: Control
var paint_mode: Control

func _enter_tree():
	dock = preload("res://addons/InstanceDock/InstanceDock.tscn").instantiate()
	dock.plugin = self
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, dock)
	paint_mode = dock.paint_mode

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()

func _handles(object: Object) -> bool:
	return paint_mode.enabled and object is CanvasItem

func _edit(object: Object) -> void:
	paint_mode.edited_node = object

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	return paint_mode.paint_input(event)

func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	paint_mode.paint_draw(viewport_control)
