@tool
extends PanelContainer

const InstanceDockPropertyEdit = preload("res://addons/InstanceDock/InstancePropertyEdit.gd")

enum MenuOption { EDIT, MODIFY, REMOVE, REFRESH, CLEAR, QUICK_LOAD }

@export var normal: StyleBox
@export var custom: StyleBox

@onready var icon := $Icon
@onready var loading_icon = $Loading
@onready var loading_animator := %AnimationPlayer
@onready var timer: Timer = $Timer
@onready var has_overrides: TextureRect = $HasOverrides
@onready var text_label: Label = %Label
@onready var paint_button: Button = $PaintButton

var popup: PopupMenu
var resource_picker: EditorResourcePicker

var plugin: EditorPlugin
var scene: String
var overrides: Dictionary
var custom_texture: String
var thread: Thread

signal request_icon(instance, ignore_cache)
signal changed

func _ready() -> void:
	set_process(false)
	
	resource_picker = EditorResourcePicker.new()
	add_child(resource_picker)
	resource_picker.hide()
	resource_picker.base_type = "PackedScene"
	resource_picker.resource_changed.connect(func(res: Resource):
		set_data({scene = res.resource_path})
		changed.emit()
	)

func _process(delta: float) -> void:
	if not thread.is_alive():
		thread.wait_to_finish()
		thread = null
		set_process(false)

func _can_drop_data(position: Vector2, data) -> bool:
	if not data is Dictionary or not "type" in data:
		return false
	
	if data.type != "files":
		return false
	
	if data.files.size() != 1:
		return false
	
	return data.files[0].get_extension() == "tscn" or is_texture(data.files[0]) and not scene.is_empty()

func _drop_data(position: Vector2, data) -> void:
	var file: String = data.files[0]
	if is_texture(file) and not scene.is_empty():
		custom_texture = file
		apply_data()
		changed.emit()
	elif file.get_extension() == "tscn":
		if "from_slot" in data:
			var slot2: Control = get_parent().get_child(data.from_slot)
			var data2: Dictionary = slot2.get_data()
			slot2.set_data(get_data())
			set_data(data2)
		else:
			scene = file
			custom_texture = ""
			apply_data()
		changed.emit()

func is_texture(file: String) -> bool:
	return ClassDB.is_parent_class(EditorInterface.get_resource_filesystem().get_file_type(file), &"Texture2D")

func _get_drag_data(position: Vector2):
	if scene.is_empty():
		return null
	
	return { files = [scene], type = "files", from_slot = get_index(), instance_dock_overrides = overrides }

func set_icon(texture: Texture2D):
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = texture
	if texture and texture.get_width() <= icon.size.x:
		icon.texture_filter = TEXTURE_FILTER_NEAREST
	
	if loading_icon.visible:
		icon.modulate.a = 0
		thread = Thread.new()
		thread.start(check_if_transparent.bind(texture.get_image()))
		set_process(true)

func check_if_transparent(data: Image):
	var is_valid: bool
	for x in data.get_width():
		for y in data.get_height():
			if data.get_pixel(x, y).a > 0:
				is_valid = true
				break
		
		if is_valid:
			break
	
	transparent_result.call_deferred(is_valid)

func transparent_result(is_valid: bool):
	icon.modulate.a = 1
	loading_icon.hide()
	loading_animator.stop()
	
	if not is_valid:
		set_icon(preload("res://addons/InstanceDock/Textures/Missing.png"))
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			create_popup()
			popup.popup()
			popup.position = get_screen_transform() * event.position
		elif event.double_click and event.button_index == MOUSE_BUTTON_LEFT and not scene.is_empty():
			menu_option(MenuOption.EDIT)

func create_popup():
	if not popup:
		popup = PopupMenu.new()
		popup.id_pressed.connect(menu_option)
		add_child(popup)
	
	popup.clear()
	
	if not scene.is_empty():
		popup.add_item("Open Scene", MenuOption.EDIT)
		popup.add_item("Override Properties", MenuOption.MODIFY)
		popup.add_item("Remove", MenuOption.REMOVE)
		if custom_texture:
			popup.add_item("Remove Custom Icon", MenuOption.CLEAR)
		else:
			popup.add_item("Refresh Icon", MenuOption.REFRESH)
	
	popup.add_item("Quick Load", MenuOption.QUICK_LOAD)
	
	popup.reset_size()

func menu_option(id: int) -> void:
	match id:
		MenuOption.EDIT:
			plugin.get_editor_interface().open_scene_from_path(scene)
		MenuOption.MODIFY:
			var editor := InstanceDockPropertyEdit.new()
			editor.instance = load(scene).instantiate()
			editor.overrides = overrides
			plugin.get_editor_interface().inspect_object(editor, "", true)
			editor.changed.connect(timer.start)
		MenuOption.REMOVE:
			scene = ""
			custom_texture = ""
			overrides.clear()
			if plugin.get_editor_interface().get_inspector().get_edited_object() is InstanceDockPropertyEdit:
				plugin.get_editor_interface().edit_node(null)
			
			changed.emit()
			apply_data()
		MenuOption.REFRESH:
			start_load()
			request_icon.emit(scene, true)
		MenuOption.CLEAR:
			custom_texture = ""
			changed.emit()
			apply_data()
		MenuOption.QUICK_LOAD:
			var popup: Popup
			
			if resource_picker.get_child_count() < 3:
				var fake_click := InputEventMouseButton.new()
				fake_click.pressed = true
				fake_click.button_index = MOUSE_BUTTON_RIGHT
				
				var edit_button: Button = resource_picker.get_child(1)
				edit_button.gui_input.emit(fake_click)
				
				popup = resource_picker.get_child(2)
				popup.hide()
			else:
				popup = resource_picker.get_child(2)
			
			popup.id_pressed.emit(1)

func get_data() -> Dictionary:
	if scene.is_empty():
		return {}
	
	var data := { scene = scene }
	if not custom_texture.is_empty():
		data.custom_texture = custom_texture
	
	if not overrides.is_empty():
		data.overrides = overrides
	
	return data

func set_data(data: Dictionary):
	scene = data.get("scene", "")
	custom_texture = data.get("custom_texture", "")
	overrides = data.get("overrides", {})
	apply_data()

func set_text_label(vis : bool):
	text_label.visible = vis

func apply_data():
	var text: PackedStringArray
	text.append(scene.get_file())
	if not overrides.is_empty():
		text.append("\nOverrides:")
		for override in overrides:
			text.append("%s: %s" % [override, overrides[override]])
	tooltip_text = "\n".join(text)
	
	set_icon(null)
	set_text_label(false)
	add_theme_stylebox_override(&"panel", normal)
	
	if scene.is_empty():
		set_icon(null)
		set_text_label(true)
	elif custom_texture.is_empty():
		start_load()
		request_icon.emit(scene, false)
	else:
		set_icon(load(custom_texture))
		add_theme_stylebox_override(&"panel", custom)
	
	paint_button.disabled = scene.is_empty()
	
	has_overrides.visible = not overrides.is_empty()

func start_load():
	loading_animator.play(&"Rotate")
	loading_icon.show()

func _on_timer_timeout() -> void:
	has_overrides.visible = not overrides.is_empty()
	apply_data()
	menu_option(MenuOption.REFRESH)

func get_hash() -> int:
	return str(scene, overrides).hash()

func setup_button(group: ButtonGroup):
	paint_button.button_group = group
