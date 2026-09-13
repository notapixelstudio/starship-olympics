@tool
extends EditorPlugin

const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
const RegistryEditor := Namespace.RegistryEditor
const TRANSLATIONS := Namespace.TRANSLATIONS
const REGISTRY_EDITOR_SCENE := Namespace.REGISTRY_EDITOR_SCENE
const FILESYSTEM_CREATE_CONTEXT_MENU_PLUGIN := Namespace.FILESYSTEM_CREATE_CONTEXT_MENU_PLUGIN
const EDITOR_INSPECTOR_PLUGIN := Namespace.EDITOR_INSPECTOR_PLUGIN

var _registry_editor: RegistryEditor
var _filesystem_create_context_menu_plugin: EditorContextMenuPlugin
var _cached_plugin_name: String


func _init() -> void:
	if not Engine.is_editor_hint():
		return

	print("YARD - Yet Another Resource Database")

	var editor_domain := TranslationServer.get_or_add_domain(&"godot.editor")
	for locale: String in TRANSLATIONS.keys():
		editor_domain.add_translation(load(TRANSLATIONS[locale]))


func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return

	_filesystem_create_context_menu_plugin = FILESYSTEM_CREATE_CONTEXT_MENU_PLUGIN.new(_filesystem_create_context_menu_plugin_callback)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE, _filesystem_create_context_menu_plugin)

	add_inspector_plugin(EDITOR_INSPECTOR_PLUGIN.new())

	_registry_editor = REGISTRY_EDITOR_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(_registry_editor)

	_reimport_icons()
	_make_visible(false)


func _exit_tree() -> void:
	if is_instance_valid(_registry_editor):
		_registry_editor.queue_free()

	if is_instance_valid(_filesystem_create_context_menu_plugin):
		remove_context_menu_plugin(_filesystem_create_context_menu_plugin)


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if is_instance_valid(_registry_editor):
		_registry_editor.visible = visible


func _handles(object: Object) -> bool:
	return object is Registry


func _edit(object: Object) -> void:
	if not object:
		return
	var edited_registry := object as Registry
	_registry_editor.open_registry(edited_registry)


func _get_plugin_name() -> String:
	if not _cached_plugin_name:
		_cached_plugin_name = tr("Registry")
	return _cached_plugin_name


func _get_plugin_icon() -> Texture2D:
	return preload("res://addons/yard/editor_only/assets/yard.svg")


# Force reimport of icons if it doesn't match the editor scale
func _reimport_icons() -> void:
	var icon: CompressedTexture2D = load("res://addons/yard/editor_only/assets/github_icon.svg")
	var scale := EditorInterface.get_editor_scale()
	if float(icon.get_width()) != scale * 16:
		print("YARD - Editor scale changed, reimporting icons. This might throw an error. Disregard.")
		EditorInterface.get_resource_filesystem().reimport_files(
			PackedStringArray(
				[
					"res://addons/yard/editor_only/assets/github_icon.svg",
					"res://addons/yard/editor_only/assets/yard.svg",
				],
			),
		)


func _filesystem_create_context_menu_plugin_callback(context: Array) -> void:
	var dir: String = context[0]
	var nrd := _registry_editor.new_registry_dialog

	nrd.popup_with_state(nrd.RegistryDialogState.NEW_REGISTRY, dir)
