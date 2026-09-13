@tool
extends Object

const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
const RegistryIO := Namespace.RegistryIO

const _BASE_DIR := "res://.godot/plugins/yard/"


class RegistryCacheData:
	const _REGISTRY_CACHE_VERSION := 2
	const _REGISTRIES_DIR := _BASE_DIR + "registries/"
	const _SECTION_GENERAL := "general"
	const _SECTION_TABLE := "table"
	const BUILTIN_RESOURCE_PROPERTIES: Array[StringName] = [
		&"script",
		&"resource_local_to_scene",
		&"resource_path",
		&"resource_name",
		&"metadata/_custom_type_script",
	]
	var version: int = _REGISTRY_CACHE_VERSION
	var disabled_columns: Array[StringName] = BUILTIN_RESOURCE_PROPERTIES.duplicate()
	var parent_props_first: bool = false
	var uid_column_width: float = 200.0
	var string_id_column_width: float = 200.0
	var property_columns_widths: Dictionary[StringName, float] = { }

	var _registry: Registry


	func _init(registry: Registry) -> void:
		_registry = registry


	func save() -> Error:
		var cfg := ConfigFile.new()
		cfg.set_value(_SECTION_GENERAL, "version", version)
		cfg.set_value(_SECTION_TABLE, "disabled_columns", disabled_columns)
		cfg.set_value(_SECTION_TABLE, "parent_props_first", parent_props_first)
		cfg.set_value(_SECTION_TABLE, "uid_column_width", uid_column_width)
		cfg.set_value(_SECTION_TABLE, "string_id_column_width", string_id_column_width)
		cfg.set_value(_SECTION_TABLE, "property_columns_widths", property_columns_widths)
		DirAccess.make_dir_recursive_absolute(_REGISTRIES_DIR)
		return cfg.save(_get_registry_cache_path(_registry))


	static func load_or_default(registry: Registry) -> RegistryCacheData:
		var data := RegistryCacheData.new(registry)
		var cfg := ConfigFile.new()
		if cfg.load(_get_registry_cache_path(registry)) != OK:
			data.save()
			return data

		data.version = cfg.get_value(_SECTION_GENERAL, "version", data.version)
		if data.version != _REGISTRY_CACHE_VERSION:
			RegistryCacheData._update_format(data, cfg)

		data.disabled_columns = cfg.get_value(_SECTION_TABLE, "disabled_columns", data.disabled_columns)
		data.parent_props_first = cfg.get_value(_SECTION_TABLE, "parent_props_first", data.parent_props_first)
		data.uid_column_width = cfg.get_value(_SECTION_TABLE, "uid_column_width", data.uid_column_width)
		data.string_id_column_width = cfg.get_value(_SECTION_TABLE, "string_id_column_width", data.string_id_column_width)
		data.property_columns_widths = cfg.get_value(_SECTION_TABLE, "property_columns_widths", data.property_columns_widths)
		return data


	static func erase(registry: Registry) -> void:
		var path := _get_registry_cache_path(registry)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


	static func _get_registry_cache_path(registry: Registry) -> String:
		var uid := ResourceUID.path_to_uid(registry.resource_path)
		var uid_str := uid.trim_prefix("uid://")
		return _REGISTRIES_DIR + uid_str + ".cfg"


	static func _update_format(_data: RegistryCacheData, _old_cfg: ConfigFile) -> void:
		# Migrate old cache formats here when _REGISTRY_CACHE_VERSION is incremented.
		if _data.version < 2:
			_data.parent_props_first = false
			_data.version = 2

		_data.version = _REGISTRY_CACHE_VERSION


class EditorStateData:
	const _EDITOR_STATE_VERSION := 1
	const _STATE_FILE := _BASE_DIR + "editor_state.cfg"
	const _SECTION_GENERAL := "general"
	const _SECTION_RECENT := "recent"
	const _MAX_RECENT := 10
	const _SECTION_OPENED := "opened"
	var version: int = _EDITOR_STATE_VERSION
	var recent_registry_uids: Array[String] = []
	var opened_registries: Dictionary[String, Registry] = { } # uid -> Registry


	func save() -> Error:
		var cfg := ConfigFile.new()
		cfg.set_value(_SECTION_GENERAL, "version", version)
		cfg.set_value(_SECTION_RECENT, "uids", recent_registry_uids.filter(RegistryIO.is_uid_valid))
		cfg.set_value(_SECTION_OPENED, "uids", opened_registries.keys().filter(RegistryIO.is_uid_valid))
		DirAccess.make_dir_recursive_absolute(_BASE_DIR)
		return cfg.save(_STATE_FILE)


	func save_and_reload() -> EditorStateData:
		var err := save()
		if err == OK:
			return load_or_default()
		else:
			return self


	static func load_or_default() -> EditorStateData:
		var data := EditorStateData.new()
		var cfg := ConfigFile.new()
		if cfg.load(_STATE_FILE) != OK:
			data.save()
			return data

		data.version = cfg.get_value(_SECTION_GENERAL, "version", data.version)
		if data.version != _EDITOR_STATE_VERSION:
			EditorStateData._update_format(data, cfg)
			data.version = _EDITOR_STATE_VERSION
			data.save()
			return data

		var raw_recent: Array = cfg.get_value(_SECTION_RECENT, "uids", [])
		data.recent_registry_uids.assign(raw_recent.filter(RegistryIO.is_uid_valid))
		var raw_opened: Array = cfg.get_value(_SECTION_OPENED, "uids", [])
		raw_opened = raw_opened.filter(RegistryIO.is_uid_valid)
		for uid: String in raw_opened:
			var path := ResourceUID.get_id_path(ResourceUID.text_to_id(uid))
			if path.is_empty():
				continue
			var registry := ResourceLoader.load(path) as Registry
			if registry:
				data.opened_registries[uid] = registry
		return data


	func add_recent(registry: Registry) -> void:
		var uid := ResourceUID.path_to_uid(registry.resource_path)
		recent_registry_uids.erase(uid)
		recent_registry_uids.push_front(uid)
		if recent_registry_uids.size() > _MAX_RECENT:
			recent_registry_uids.resize(_MAX_RECENT)
		save()


	func clear_recent() -> void:
		recent_registry_uids.clear()
		save()


	static func _update_format(_data: EditorStateData, _old_cfg: ConfigFile) -> void:
		# Migrate old state formats here when _EDITOR_STATE_VERSION is incremented.
		pass
