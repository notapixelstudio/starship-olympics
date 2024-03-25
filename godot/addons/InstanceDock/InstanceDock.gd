@tool
extends Control

const PROJECT_SETTING = "addons/instance_dock/scenes"
const PROJECT_SETTING2 = "addons/instance_dock/preview_resolution"
var PREVIEW_SIZE = Vector2i(64, 64)

@onready var tabs := %Tabs
@onready var tab_add_confirm := %AddTabConfirm
@onready var tab_add_name := %AddTabName
@onready var tab_delete_confirm := %DeleteConfirm

@onready var scroll := %ScrollContainer
@onready var slot_container := %Slots
@onready var add_tab_label := %AddTabLabel
@onready var drag_label := %DragLabel

@onready var extras_toggle: Button = %ExtrasToggle
@onready var extras: VBoxContainer = %Extras
@onready var parent_selector: HBoxContainer = %ParentSelector
@onready var parent_icon: TextureRect = %ParentIcon
@onready var parent_name: LineEdit = %ParentName
@onready var paint_mode: VBoxContainer = %PaintMode

@onready var icon_generator := $Viewport

var data: Array
var initialized: int

var icon_cache: Dictionary
var previous_tab: int

var tab_to_remove := -1
var icon_queue: Array[Dictionary]
var icon_progress: int
var current_processed_item: Dictionary

var default_parent: Node

var plugin: EditorPlugin

func _ready() -> void:
	set_process(false)
	DirAccess.make_dir_recursive_absolute(".godot/InstanceIconCache")
	
	if not plugin:
		return
	
	if ProjectSettings.has_setting(PROJECT_SETTING):
		data = ProjectSettings.get_setting(PROJECT_SETTING)
	else:
		ProjectSettings.set_setting(PROJECT_SETTING, data)
	
	if ProjectSettings.has_setting(PROJECT_SETTING2):
		PREVIEW_SIZE = ProjectSettings.get_setting(PROJECT_SETTING2)
	else:
		ProjectSettings.set_setting(PROJECT_SETTING2, PREVIEW_SIZE)
	icon_generator.size = PREVIEW_SIZE
	
	plugin.project_settings_changed.connect(update_preview_size)
	
	for tab in data:
		tabs.add_tab(tab.name)
	
	plugin.scene_changed.connect(on_scene_changed.unbind(1))
	
	extras.hide()
	parent_selector.set_drag_forwarding(Callable(), _can_drop_node, _drop_node)

func update_preview_size():
	if ProjectSettings.has_setting(PROJECT_SETTING2):
		var new_preview_size: Vector2i = ProjectSettings.get_setting(PROJECT_SETTING2)
		if new_preview_size != PREVIEW_SIZE:
			PREVIEW_SIZE = new_preview_size
			icon_generator.size = PREVIEW_SIZE

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN:
		var drag_data = get_viewport().gui_get_drag_data()
		if drag_data is Dictionary and "instance_dock_overrides" in drag_data:
			get_tree().node_added.connect(node_added)
	elif what == NOTIFICATION_DRAG_END:
		if get_tree().node_added.is_connected(node_added):
			get_tree().node_added.disconnect(node_added)
	
	if initialized == 2:
		return
	
	if what == NOTIFICATION_ENTER_TREE:
		initialized = 1
	
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree() and slot_container != null and initialized == 1:
			refresh_tab_contents()
			initialized = 2

func node_added(node: Node):
	var scene := plugin.get_editor_interface().get_edited_scene_root()
	if not scene or not scene.is_ancestor_of(node):
		return
	
	var drag_data = get_viewport().gui_get_drag_data()
	if not "files" in drag_data or not node.scene_file_path in drag_data["files"]:
		return
	
	var overrides: Dictionary = drag_data["instance_dock_overrides"]
	for override in overrides:
		node.set(override, overrides[override])
	
	if node.get_parent() == EditorInterface.get_edited_scene_root():
		var parent := get_default_parent()
		
		if parent and node.get_parent() != parent:
			do_reparent.call_deferred(node, parent)

func do_reparent(node: Node, to: Node):
	var undo_redo := plugin.get_undo_redo()
	undo_redo.create_action("InstanceDock reparent node")
	undo_redo.add_do_method(node, &"reparent", to)
	undo_redo.add_do_method(node, &"set_owner", node.owner)
	undo_redo.add_do_method(node, &"set_name", node.name)
	undo_redo.add_undo_method(node, &"reparent", node.get_parent())
	undo_redo.add_undo_method(node, &"set_owner", node.owner)
	undo_redo.add_undo_method(node, &"set_name", node.name)
	undo_redo.commit_action()

func on_add_tab_pressed() -> void:
	tab_add_name.text = ""
	tab_add_confirm.reset_size()
	tab_add_confirm.popup_centered()
	tab_add_name.grab_focus.call_deferred()

func add_tab_confirm(q = null) -> void:
	if q != null:
		tab_add_confirm.hide()
	
	tabs.add_tab(tab_add_name.text)
	data.append({name = tab_add_name.text, scenes = [], scroll = 0})
	ProjectSettings.save()
	
	if data.size() == 1:
		refresh_tab_contents()

func on_tab_close_attempt(tab: int) -> void:
	tab_to_remove = tab
	tab_delete_confirm.popup_centered()

func remove_tab_confirm() -> void:
	if tab_to_remove != tabs.current_tab:
		tab_to_remove = -1
	data.remove_at(tab_to_remove)
	tabs.remove_tab(tab_to_remove)
	ProjectSettings.save()
	
	if tabs.tab_count == 0:
		refresh_tab_contents()

func on_tab_changed(tab: int) -> void:
	if tab_to_remove == -1 and data.size() > 0:
		data[previous_tab].scroll = scroll.scroll_vertical
	tab_to_remove = -1
	previous_tab = tab
	
	if initialized == 2:
		refresh_tab_contents()

func refresh_tab_contents():
	for c in slot_container.get_children():
		c.free()
	
	if tabs.tab_count == 0:
		slot_container.hide()
		add_tab_label.show()
		drag_label.hide()
		return
	else:
		slot_container.show()
		add_tab_label.hide()
		drag_label.show()
	
	if data.size() > 0:
		var tab_data: Dictionary = data[tabs.current_tab]
		var scenes: Array = tab_data.scenes
	
		adjust_slot_count()
		for i in slot_container.get_child_count():
			if i < scenes.size() and not scenes[i].is_empty():
				slot_container.get_child(i).set_data(scenes[i])
			else:
				slot_container.get_child(i).set_data({})
		
		scroll.scroll_vertical = tab_data.scroll
	
	if paint_mode.enabled:
		paint_mode.set_paint_mode_enabled(true)

func remove_scene(slot: int):
	var tab_scenes: Array = data[tabs.current_tab].scenes
	tab_scenes[slot] = {}
	while not tab_scenes.is_empty() and tab_scenes.back().is_empty():
		tab_scenes.pop_back()

func _process(delta: float) -> void:
	if icon_queue.is_empty() and current_processed_item.is_empty():
		set_process(false)
		return
	
	if current_processed_item.is_empty():
		get_item_from_queue()
	
	var slot = current_processed_item.slot
	
	if "png" in current_processed_item:
		icon_cache[slot.get_hash()] = current_processed_item.png
		slot.set_icon(current_processed_item.png)
		get_item_from_queue()
		return
	
	var instance: Node = current_processed_item.instance
	
	var overrides: Dictionary = current_processed_item.overrides
	for override in overrides:
		instance.set(override, overrides[override])
	
	while not is_instance_valid(slot):
		icon_progress = 0
		instance.free()
		get_item_from_queue()
		
		if current_processed_item.is_empty():
			return
		else:
			instance = current_processed_item.instance
			slot = current_processed_item.slot
	
	match icon_progress:
		0:
			icon_generator.add_child(instance)
			if instance is Node2D:
				instance.position = PREVIEW_SIZE / 2
		3:
			var image = icon_generator.get_texture().get_image()
			image.save_png(".godot/InstanceIconCache/%s.png" % slot.get_hash())
			var texture = ImageTexture.create_from_image(image)
			slot.set_icon(texture)
			icon_cache[slot.get_hash()] = texture
			instance.free()
			
			icon_progress = -1
			get_item_from_queue()
	
	icon_progress += 1

func get_item_from_queue():
	if icon_queue.is_empty():
		current_processed_item = {}
		return
	
	current_processed_item = icon_queue.pop_front()
	if "png" in current_processed_item:
		var texture := ImageTexture.create_from_image(Image.load_from_file(current_processed_item.png))
		current_processed_item.png = texture
	else:
		current_processed_item.instance = load(current_processed_item.scene).instantiate()
		current_processed_item.overrides = current_processed_item.slot.overrides

func assign_icon(scene_path: String, ignore_cache: bool, slot: Control):
	if not ignore_cache:
		var hash: int = slot.get_hash()
		var icon := icon_cache.get(hash) as Texture2D
		if icon:
			slot.set_icon(icon)
			return
		else:
			var cache_path := ".godot/InstanceIconCache/%s.png" % hash
			if FileAccess.file_exists(cache_path):
				icon_queue.append({ png = cache_path, slot = slot })
				set_process(true)
				return
	generate_icon(scene_path, slot)

func generate_icon(scene_path: String, slot: Control):
	icon_queue.append({scene = scene_path, slot = slot})
	set_process(true)

func add_slot() -> Control:
	var slot = preload("res://addons/InstanceDock/InstanceSlot.tscn").instantiate()
	slot.plugin = plugin
	slot_container.add_child(slot)
	slot.setup_button(paint_mode.buttons)
	slot.request_icon.connect(assign_icon.bind(slot))
	slot.changed.connect(recreate_tab_data, CONNECT_DEFERRED)
	return slot

func recreate_tab_data():
	var tab_scenes: Array = data[tabs.current_tab].scenes
	tab_scenes.clear()
	
	for slot in slot_container.get_children():
		tab_scenes.append(slot.get_data())
	
	while not tab_scenes.is_empty() and tab_scenes.back().is_empty():
		tab_scenes.pop_back()
	
	ProjectSettings.save()
	adjust_slot_count()

func adjust_slot_count():
	var tab_scenes: Array[Dictionary]
	tab_scenes.assign(data[tabs.current_tab].scenes)
	var desired_slots := tab_scenes.size() + 1
	
	while desired_slots > slot_container.get_child_count():
		add_slot()
	
	while desired_slots < slot_container.get_child_count():
		slot_container.get_child(slot_container.get_child_count() - 1).free()

func on_rearrange(idx_to: int) -> void:
	var old_data: Dictionary = data[previous_tab]
	data[previous_tab] = data[idx_to]
	data[idx_to] = old_data
	previous_tab = idx_to
	ProjectSettings.save()

func toggle_extras() -> void:
	extras.visible = not extras.visible
	if extras.visible:
		extras_toggle.icon = preload("res://addons/InstanceDock/Textures/Collapse.svg")
	else:
		extras_toggle.icon = preload("res://addons/InstanceDock/Textures/Uncollapse.svg")

func set_default_parent(node: Node):
	if default_parent == node and not (default_parent and not node):
		return
	
	default_parent = node
	if node:
		parent_icon.show()
		parent_icon.texture = get_theme_icon(node.get_class(), &"EditorIcons")
		parent_name.text = node.name
		parent_selector.tooltip_text = EditorInterface.get_edited_scene_root().get_path_to(node)
	else:
		parent_icon.hide()
		parent_name.text = ""
		parent_selector.tooltip_text = ""

func get_default_parent() -> Node:
	var parent := default_parent
	if is_instance_valid(parent):
		if not parent.is_inside_tree():
			set_default_parent(null)
		else:
			return parent
	elif parent:
		set_default_parent(null)
	return null

func on_scene_changed():
	set_default_parent(null)

func _can_drop_node(at: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false
	
	if not data.get("type", "") == "nodes":
		return false
	
	if not "nodes" in data or not data["nodes"] is Array:
		return false
	
	if data["nodes"].size() != 1 or not data["nodes"][0] is NodePath:
		return false
	
	return true

func _drop_node(at: Vector2, data: Variant):
	var node: Node = get_tree().root.get_node_or_null(data["nodes"][0])
	if not node:
		return
	
	set_default_parent(node)
