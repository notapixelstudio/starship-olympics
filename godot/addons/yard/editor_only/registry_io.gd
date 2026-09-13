@tool
extends Object

const Namespace := preload("res://addons/yard/editor_only/namespace.gd")
const ClassUtils := Namespace.ClassUtils

const REGISTRY_FILE_EXTENSIONS := ["tres"]
const LOGGING_INFO_COLOR := "lightslategray"


static func create_registry_file(path: String, settings: RegistrySettings = null) -> Error:
	path = path.strip_edges()

	if path.is_empty() or not is_valid_registry_output_path(path):
		return ERR_FILE_BAD_PATH

	if ResourceLoader.exists(path):
		return ERR_FILE_CANT_WRITE

	var registry := Registry.new()

	if settings:
		var err := _apply_settings(registry, settings)
		if err != OK:
			return err

	var save_err := ResourceSaver.save(registry, path, ResourceSaver.FLAG_CHANGE_PATH)

	var uid_int := ResourceUID.create_id()
	ResourceSaver.set_uid(path, uid_int)
	if not ResourceUID.has_id(uid_int):
		# Ensures the UID is in the in-memory cache, not just on disk
		ResourceUID.add_id(uid_int, path)

	EditorInterface.get_resource_filesystem().scan()
	return save_err


static func get_registry_settings(registry: Registry) -> RegistrySettings:
	# TODO: Create a migration to handle the actual conversion of registry setting values.
	# This is only a temporary implementation!
	if registry._version >= 2:
		var settings := RegistrySettings.new()
		settings.version = registry._version
		settings.indexed_props = ",".join(registry._property_index.keys())
		settings.auto_rescan = registry._scan_auto
		settings.remove_unmatched = registry._scan_remove

		var scan_rulesets_count := registry._scan_rulesets.size()
		if scan_rulesets_count > 0:
			settings.default_scan_ruleset = RegistryScanRuleset.get_ruleset_from_dict(registry._scan_rulesets[0], false)
			for i in scan_rulesets_count - 1:
				settings.additional_scan_rulesets.append(RegistryScanRuleset.get_ruleset_from_dict(registry._scan_rulesets[i + 1], true))

		return settings

	else:
		# Temporary handling of old V1 properties to the V2 format
		var settings := RegistrySettings.new()
		settings.version = registry._version
		settings.indexed_props = ",".join(registry._property_index.keys())
		settings.auto_rescan = registry._scan_auto
		settings.remove_unmatched = registry._scan_remove

		var default_scan_ruleset := RegistryScanRuleset.new()
		default_scan_ruleset.class_restrictions = [registry._class_restriction]
		default_scan_ruleset.scan_directories = [_normalize_abs_path(registry._scan_directory)]
		default_scan_ruleset.recursive_scan = registry._recursive_scan
		default_scan_ruleset.allowed_file_extensions = []
		default_scan_ruleset.scan_regex_include = registry._scan_regex_include
		default_scan_ruleset.scan_regex_exclude = registry._scan_regex_exclude

		settings.default_scan_ruleset = default_scan_ruleset
		settings.additional_scan_rulesets = []

		return settings


static func set_registry_settings(registry: Registry, settings: RegistrySettings) -> Error:
	var err := _apply_settings(registry, settings)
	if err != OK:
		return err

	var all_class_restrictions := settings.get_all_class_restrictions()
	for uid in registry.get_all_uids():
		if not does_resource_match_class_restrictions(load(uid), all_class_restrictions):
			erase_entry(registry, uid)

	return ResourceSaver.save(registry)


## add a new Resource to the Registry from a UID.
## If no string_id is given, it will use the file basename.
## If the string_id is already used in the Registry, it will append a number to it.
static func add_entry(registry: Registry, uid: StringName, string_id: String = "") -> Error:
	var cache_id: int = ResourceUID.text_to_id(uid)
	if not ResourceUID.has_id(cache_id):
		return ERR_CANT_ACQUIRE_RESOURCE

	if string_id.begins_with(("uid://")):
		return ERR_INVALID_PARAMETER

	if uid in registry._uids_to_string_ids:
		return ERR_ALREADY_EXISTS

	var settings := get_registry_settings(registry)
	if settings.has_any_class_restrictions() and not does_resource_match_class_restrictions(load(uid), settings.get_all_class_restrictions()):
		return ERR_DATABASE_CANT_WRITE

	if not string_id:
		### WARNING the following lines have been customized for Starship Olympics
		var path = ResourceUID.get_id_path(cache_id)
		string_id = path.get_base_dir().get_slice('/',path.get_base_dir().get_slice_count('/')-1) + '_' + path.get_file().get_basename()
		###
		
	if string_id in registry._string_ids_to_uids:
		string_id = _make_string_id_unique(registry, string_id)

	registry._uids_to_string_ids[uid] = string_id as StringName
	registry._string_ids_to_uids[string_id] = uid

	return ResourceSaver.save(registry)


static func erase_entry(registry: Registry, id: StringName) -> Error:
	var uid := registry.get_uid(id)
	if not uid:
		return ERR_INVALID_PARAMETER

	registry._string_ids_to_uids.erase(registry.get_string_id(uid))
	registry._uids_to_string_ids.erase(uid)

	return ResourceSaver.save(registry)


static func rename_entry(
		registry: Registry,
		id: StringName,
		new_string_id: StringName,
) -> Error:
	var uid := registry.get_uid(id)
	if not uid:
		return ERR_INVALID_PARAMETER

	registry._string_ids_to_uids.erase(id)
	var unique_new_string_id := _make_string_id_unique(registry, new_string_id)
	registry._string_ids_to_uids[unique_new_string_id] = uid
	registry._uids_to_string_ids[uid] = unique_new_string_id
	return ResourceSaver.save(registry)


static func change_entry_uid(registry: Registry, id: StringName, new_uid: StringName) -> Error:
	var old_uid := registry.get_uid(id)
	if not old_uid:
		return ERR_INVALID_PARAMETER

	var string_id := registry.get_string_id(old_uid)
	if registry.has_uid(new_uid):
		var already_there_string_id := registry.get_string_id(new_uid)
		push_error(
			"UID Change Error: You can't use %s for '%s', as it's already in the registry as '%s'" % [
				new_uid,
				string_id,
				already_there_string_id,
			],
		)
		return ERR_INVALID_PARAMETER

	var settings := get_registry_settings(registry)

	if settings.has_any_class_restrictions():
		var res := load(new_uid)
		var all_class_restrictions := settings.get_all_class_restrictions()
		if not does_resource_match_class_restrictions(res, all_class_restrictions):
			push_error(
				"UID Change Error: The associated resource '%s' doesn't match the registry class restriction (%s)." % [
					res.resource_path.get_file(),
					",".join(all_class_restrictions),
				],
			)
			return ERR_INVALID_PARAMETER

	registry._uids_to_string_ids.erase(old_uid)
	registry._uids_to_string_ids[new_uid] = string_id
	registry._string_ids_to_uids[string_id] = new_uid
	return ResourceSaver.save(registry)


static func sync_from_scan_directories(registry: Registry) -> void:
	var settings := get_registry_settings(registry)
	var all_scan_dirs := settings.get_all_scan_directories()
	if all_scan_dirs.is_empty():
		return
	# Validate before applying new settings
	for scan_dir in all_scan_dirs:
		if not scan_dir or not DirAccess.dir_exists_absolute(scan_dir):
			return

	var n_added := 0
	var n_removed := 0
	var first_added := ""
	var first_removed := ""
	var scanned_uids := { }

	var _log := func(action: String, prep: String, n: int, first: String) -> void:
		if n == 1:
			print_rich(
				"[color=%s]%s %s %s %s.[/color]" % [
					LOGGING_INFO_COLOR,
					action.capitalize(),
					first,
					prep,
					registry.resource_path.get_file(),
				],
			)
		elif n > 1:
			print_rich(
				"[color=%s]%s %s and %d more entr%s %s %s.[/color]" % [
					LOGGING_INFO_COLOR,
					action.capitalize(),
					first,
					n - 1,
					"ies" if n > 2 else "y",
					prep,
					registry.resource_path.get_file(),
				],
			)

	# Add
	for scan_ruleset in settings.get_compiled_rulesets():
		for scan_dir in scan_ruleset.scan_directories:
			for res in dir_get_matching_resources(scan_dir, scan_ruleset, scan_dir):
				var uid := ResourceUID.path_to_uid(res.resource_path)
				scanned_uids[uid] = true
				if add_entry(registry, uid) == OK:
					n_added += 1
					if n_added == 1:
						first_added = registry.get_string_id(uid)

	_log.call("added", "to", n_added, first_added)

	# Remove
	if not registry._scan_remove:
		return

	for uid in registry.get_all_uids():
		if scanned_uids.has(uid):
			continue
		var string_id := registry.get_string_id(uid)
		if erase_entry(registry, StringName(uid)) == OK:
			n_removed += 1
			if n_removed == 1:
				first_removed = string_id
		else:
			print_rich(
				"[color=%s]Failed to remove %s from %s.[/color]" % [
					LOGGING_INFO_COLOR,
					string_id,
					registry.resource_path.get_file(),
				],
			)

	_log.call("removed", "from", n_removed, first_removed)


## Rebuilds the property index by loading every registered resource and reading
## the currently indexed properties.[br][br]
##
## This is a blocking operation — it loads all resources synchronously.
## Only properties already registered via [method add_indexed_property] are indexed.
## Entries whose resource cannot be loaded are skipped.
static func rebuild_property_index(registry: Registry) -> Error:
	# Clear existing values while keeping registered property keys
	for property: StringName in registry._property_index:
		registry._property_index[property] = { }

	for uid: StringName in registry.get_all_uids():
		if not is_uid_valid(uid):
			continue
		var res := load(uid)
		if res == null:
			continue
		var string_id := registry.get_string_id(uid)
		for property: StringName in registry._property_index.keys():
			var value: Variant = _resolve_property_path(res, property)
			if value == null:
				continue
			if not registry._property_index[property].has(value):
				registry._property_index[property][value] = { }
			registry._property_index[property][value][string_id] = true

	return ResourceSaver.save(registry)


## NOTE: Only one of the ruleset's scan directories can be checked at a time! When multiple are
## defined, they should be iterated through in a parent scope.
static func dir_has_matching_resource(path: String, scan_ruleset: RegistryScanRuleset, base_scan_dir: String, ignore_scan_filters: bool = false, compiled_re_in: RegEx = null, compiled_re_ex: RegEx = null) -> bool:
	var recursive := scan_ruleset.recursive_scan
	var re_include := compiled_re_in if compiled_re_in else _compile_regex(scan_ruleset.scan_regex_include)
	var re_exclude := compiled_re_ex if compiled_re_ex else _compile_regex(scan_ruleset.scan_regex_exclude)
	var dir := DirAccess.open(path)
	if dir == null:
		return false

	dir.list_dir_begin()
	var next: String = dir.get_next()

	while next != "":
		var abs_next_path: String = dir.get_current_dir().path_join(next)
		var rel_next_path := abs_next_path.replace(base_scan_dir + "/", "")

		if recursive and dir.current_is_dir() and (ignore_scan_filters or _path_passes_scan_filters(rel_next_path, null, re_exclude)):
			if dir_has_matching_resource(abs_next_path, scan_ruleset, base_scan_dir, ignore_scan_filters, re_include, re_exclude):
				dir.list_dir_end()
				return true
		elif ResourceLoader.exists(abs_next_path) and (ignore_scan_filters or _path_passes_scan_filters(rel_next_path, re_include, re_exclude, scan_ruleset.allowed_file_extensions)):
			var res := load(abs_next_path)
			if does_resource_match_class_restrictions(res, scan_ruleset.class_restrictions):
				dir.list_dir_end()
				return true

		next = dir.get_next()
	return false


## NOTE: Only one of the ruleset's scan directories can be checked at a time! When multiple are
## defined, they should be iterated through in a parent scope.
static func dir_get_matching_resources(path: String, scan_ruleset: RegistryScanRuleset, base_scan_dir: String, ignore_scan_filters: bool = false, compiled_re_in: RegEx = null, compiled_re_ex: RegEx = null) -> Array[Resource]:
	var recursive := scan_ruleset.recursive_scan
	var re_include := _compile_regex(scan_ruleset.scan_regex_include) if not compiled_re_in else compiled_re_in
	var re_exclude := _compile_regex(scan_ruleset.scan_regex_exclude) if not compiled_re_ex else compiled_re_ex
	var dir := DirAccess.open(path)
	if not path or not dir:
		return []

	dir.list_dir_begin()
	var next: String = dir.get_next()
	var matching_resources: Array[Resource] = []

	while next != "":
		var abs_next_path: String = dir.get_current_dir().path_join(next)
		var rel_next_path := abs_next_path.replace(base_scan_dir, "")
		if rel_next_path.begins_with("/"):
			rel_next_path = rel_next_path.substr(1)

		# Do not match the include pattern against directories, as it's a partial path. Only match on leaf (file) paths.
		if recursive and dir.current_is_dir() and (ignore_scan_filters or _path_passes_scan_filters(rel_next_path, null, re_exclude)):
			matching_resources += dir_get_matching_resources(abs_next_path, scan_ruleset, base_scan_dir, ignore_scan_filters, re_include, re_exclude)
		elif ResourceLoader.exists(abs_next_path) and (ignore_scan_filters or _path_passes_scan_filters(rel_next_path, re_include, re_exclude, scan_ruleset.allowed_file_extensions)):
			var res := load(abs_next_path)
			if does_resource_match_class_restrictions(res, scan_ruleset.class_restrictions):
				matching_resources.append(res)

		next = dir.get_next()

	dir.list_dir_end()
	return matching_resources


static func is_valid_registry_output_path(path: String) -> bool:
	path = path.strip_edges()
	if path.is_empty():
		return false

	if path.begins_with("res://"):
		path = path.trim_prefix("res://")

	var dir_rel := path.get_base_dir()
	var file := path.get_file()

	if file.is_empty() or not file.is_valid_filename():
		return false

	var dir_abs := "res://" + dir_rel
	return DirAccess.dir_exists_absolute(dir_abs)


## Returns true if [param res] matches the defined [class_restrictions].
## Handles native classes, named scripts (class_name), and unnamed scripts (quoted path).
## Subclasses of the class restrictions are accepted.
static func does_resource_match_class_restrictions(
		res: Resource,
		class_restrictions: Array[StringName],
) -> bool:
	if res == null:
		return false

	if class_restrictions.is_empty():
		return true

	for class_restriction in class_restrictions:
		if is_quoted_string(class_restriction):
			var restriction_script_path := unquote(class_restriction)
			var resource_script: Script = res.get_script()
			if not resource_script or not ResourceLoader.exists(restriction_script_path):
				continue

			var restriction_script := load(restriction_script_path) as Script
			if not restriction_script:
				continue

			if restriction_script in ClassUtils.get_script_inheritance_list(resource_script, true):
				return true

		elif ClassUtils.is_class_of(res, class_restriction):
			return true

	return false


## Returns true if [param class_string] names a valid Resource subclass.[br]
## Accepts native class names, script class_names, and quoted script paths.
static func is_resource_class_string(class_string: String) -> bool:
	class_string = class_string.strip_edges()
	if class_string.is_empty():
		return false

	if is_quoted_string(class_string):
		var path := unquote(class_string)
		if not ResourceLoader.exists(path):
			return false
		var script := load(path) as Script
		if script == null:
			return false
		return ClassUtils.is_class_of(script, "Resource")
	else:
		return ClassUtils.is_class_of(class_string, "Resource")


static func is_uid_valid(uid: String) -> bool:
	return ResourceUID.has_id(ResourceUID.text_to_id(uid))


static func is_valid_regex_pattern(pattern: String) -> bool:
	if pattern.is_empty():
		return true
	var re := RegEx.new()
	return re.compile(pattern, false) == OK


## Returns true if [param string] is wrapped in matching single or double quotes.
static func is_quoted_string(string: String) -> bool:
	if string.length() < 2:
		return false
	var first := string[0]
	var last := string[-1]
	return (first == "\"" and last == "\"") or (first == "'" and last == "'")


static func would_erase_entries(registry: Registry, new_scan_settings: RegistrySettings) -> bool:
	var all_class_restrictions := new_scan_settings.get_all_class_restrictions()
	for uid: StringName in registry.get_all_uids():
		if not is_uid_valid(uid):
			continue

		if not does_resource_match_class_restrictions(load(uid), all_class_restrictions):
			return true

	return false


## Strips the surrounding quotes from a quoted string.
## Call [method is_quoted_string] first to ensure the input is valid.
static func unquote(string: String) -> String:
	return string.substr(1, string.length() - 2)


static func _compile_regex(pattern: String) -> RegEx:
	if pattern.is_empty():
		return null
	return RegEx.create_from_string(pattern)


static func _path_passes_scan_filters(path: String, re_include: RegEx, re_exclude: RegEx, file_extensions_filter: Array[String] = []) -> bool:
	if re_include and not re_include.search(path):
		return false
	if re_exclude and re_exclude.search(path):
		return false
	if not file_extensions_filter.is_empty():
		var any_file_extension_matches := false
		for file_extension in file_extensions_filter:
			if path.ends_with(file_extension):
				any_file_extension_matches = true
				break
		if not any_file_extension_matches:
			return false
	return true


static func _apply_settings(registry: Registry, settings: RegistrySettings) -> Error:
	# Validate before applying new settings
	for class_restriction in settings.get_all_class_restrictions():
		if class_restriction and not is_resource_class_string(class_restriction):
			return ERR_DOES_NOT_EXIST

	for scan_dir in settings.get_all_scan_directories():
		if scan_dir and not DirAccess.dir_exists_absolute(scan_dir):
			return ERR_DOES_NOT_EXIST

	registry._version = settings.version
	registry._scan_auto = settings.auto_rescan
	registry._scan_remove = settings.remove_unmatched

	var scan_ruleset_dicts: Array[Dictionary] = []
	scan_ruleset_dicts.append(settings.default_scan_ruleset.to_dict(false))
	for additional_ruleset in settings.additional_scan_rulesets:
		scan_ruleset_dicts.append(additional_ruleset.to_dict(true))
	registry._scan_rulesets = scan_ruleset_dicts

	var props: Array[StringName] = []
	for p: String in settings.indexed_props.split(",", false):
		props.append(StringName(p.strip_edges()))
	_replace_indexed_properties_list(registry, props)

	return OK


static func _make_string_id_unique(registry: Registry, string_id: String) -> String:
	if not string_id in registry._string_ids_to_uids:
		return string_id

	var regex := RegEx.new()
	regex.compile("(_\\d+)$")
	string_id = regex.sub(string_id, "", true)

	var id_to_try := string_id
	var n := 2
	while id_to_try + "_" + str(n) in registry._string_ids_to_uids:
		n += 1
	return id_to_try + "_" + str(n)


## Reconciles the set of indexed properties to match [param properties] exactly.[br][br]
##
## Properties in [param properties] not yet indexed are added.
## Properties currently indexed but absent from [param properties] are removed.
## Existing index data for kept properties is preserved. Call
## [method rebuild_property_index] afterwards to refresh values.
static func _replace_indexed_properties_list(registry: Registry, properties: Array[StringName]) -> void:
	var target := { }
	for p in properties:
		target[p] = true

	for existing: StringName in registry._property_index.keys():
		if not target.has(existing):
			registry._property_index.erase(existing)

	for p in properties:
		if not registry._property_index.has(p):
			registry._property_index[p] = { }


static func _resolve_property_path(obj: Object, path: StringName) -> Variant:
	var parts := String(path).split(".", false)
	var current: Variant = obj
	for part: String in parts:
		if not current is Object:
			return null
		current = (current as Object).get(part)
		if current == null:
			return null
	return current


static func _normalize_abs_path(path: String) -> String:
	if path.is_empty() or not path.is_absolute_path():
		return ""
	var normalized_path := path.simplify_path()
	if not normalized_path.begins_with("res://"):
		normalized_path = "res://" + normalized_path
	if not normalized_path == "res://" and normalized_path.ends_with("/"):
		normalized_path = normalized_path.substr(0, normalized_path.length() - 1)
	return normalized_path


class RegistrySettings:
	var version: int = Registry._REGISTRY_FORMAT_VERSION
	var indexed_props: String = ""
	var auto_rescan: bool = true
	var remove_unmatched: bool = true
	var default_scan_ruleset: RegistryScanRuleset = RegistryScanRuleset.new()
	var additional_scan_rulesets: Array[RegistryScanRuleset] = []


	## Apply scan property overrides on all additional rulesets, and return every ruleset in a
	## single list that can be read from without further read calculations.
	func get_compiled_rulesets() -> Array[RegistryScanRuleset]:
		var compiled_rulesets: Array[RegistryScanRuleset] = [default_scan_ruleset]
		for additional_scan_ruleset in additional_scan_rulesets:
			compiled_rulesets.append(additional_scan_ruleset.compile_with_overridden_properties(default_scan_ruleset))
		return compiled_rulesets


	func has_any_class_restrictions() -> bool:
		if not default_scan_ruleset.class_restrictions.is_empty():
			return true
		for additional_scan_ruleset in additional_scan_rulesets:
			if not additional_scan_ruleset.class_restrictions.is_empty():
				return true
		return false


	func get_all_class_restrictions() -> Array[StringName]:
		var all_class_restrictions: Array[StringName] = default_scan_ruleset.class_restrictions.duplicate()
		for additional_scan_ruleset in additional_scan_rulesets:
			if additional_scan_ruleset.override_properties.has(&"class_restrictions"):
				for additional_class_restriction in additional_scan_ruleset.class_restrictions:
					if not all_class_restrictions.has(additional_class_restriction):
						all_class_restrictions.append(additional_class_restriction)
		return all_class_restrictions


	func get_all_scan_directories() -> Array[String]:
		var all_scan_directories: Array[String] = default_scan_ruleset.scan_directories.duplicate()
		for additional_scan_ruleset in additional_scan_rulesets:
			if additional_scan_ruleset.override_properties.has(&"scan_directories"):
				for additional_scan_directory in additional_scan_ruleset.scan_directories:
					if not all_scan_directories.has(additional_scan_directory):
						all_scan_directories.append(additional_scan_directory)
		return all_scan_directories


## Defines how a scanning operation should run, including which directories should be checked & what
## restrictions to impose on them.
class RegistryScanRuleset:
	const RULESET_PROPERTY_KEYS: Array[StringName] = [
		&"class_restrictions",
		&"scan_directories",
		&"recursive_scan",
		&"allowed_file_extensions",
		&"scan_regex_include",
		&"scan_regex_exclude",
	]

	var class_restrictions: Array[StringName] = []
	var scan_directories: Array[String] = []
	var recursive_scan: bool = false
	var allowed_file_extensions: Array[String] = []
	var scan_regex_include: String = ""
	var scan_regex_exclude: String = ""
	## Only relevant for non-default scan rulesets - defines which of these scan properties should
	## actually be used vs. which should be inherited from the default settings.
	var override_properties: Array[StringName] = []


	## Determine whether two rulesets match. For either ruleset, a default 'fallback' ruleset can be
	## optionally specified, implying that this is an additional ruleset that should only compare
	## its overridden properties rather than all properties.
	func matches_other_ruleset(
			other_ruleset: RegistryScanRuleset,
			default_ruleset: RegistryScanRuleset = null,
			other_default_ruleset: RegistryScanRuleset = null,
	) -> bool:
		for property_key in RULESET_PROPERTY_KEYS:
			var our_value: Variant = (
				self[property_key] if default_ruleset == null or self.override_properties.has(property_key)
				else default_ruleset[property_key]
			)
			var their_value: Variant = (
				other_ruleset[property_key] if other_default_ruleset == null or other_ruleset.override_properties.has(property_key)
				else other_default_ruleset[property_key]
			)
			if our_value != their_value:
				return false

		return true


	## Make a copy of this ruleset with compiled rules taken overridden fields + non-overridden ones from the default ruleset.
	## Only applicable for non-default rulesets.
	func compile_with_overridden_properties(default_ruleset: RegistryScanRuleset) -> RegistryScanRuleset:
		var compiled_ruleset := RegistryScanRuleset.new()
		for property_key in RULESET_PROPERTY_KEYS:
			compiled_ruleset[property_key] = self[property_key] if override_properties.has(property_key) else default_ruleset[property_key]
		return compiled_ruleset


	## Convert this ruleset to a dictionary format (usually to store to a resource file).
	func to_dict(is_additional_ruleset: bool) -> Dictionary:
		var dict := { }
		for property_key in RULESET_PROPERTY_KEYS:
			if not is_additional_ruleset or property_key in override_properties:
				dict[property_key] = self[property_key]
		return dict


	## Generate a ruleset from a dictionary (usually stored to a resource file).
	static func get_ruleset_from_dict(dict: Dictionary, is_additional_ruleset: bool) -> RegistryScanRuleset:
		var new_ruleset := RegistryScanRuleset.new()
		for property_key in RULESET_PROPERTY_KEYS:
			if dict.has(property_key):
				# TODO: Should we account for mismatched types here?
				new_ruleset[property_key] = dict[property_key]
				if is_additional_ruleset:
					new_ruleset.override_properties.append(property_key)
		return new_ruleset
