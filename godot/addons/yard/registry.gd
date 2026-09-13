@tool
@icon("res://addons/yard/editor_only/assets/yard.svg")
@warning_ignore_start("unused_private_class_variable")
class_name Registry
extends Resource
## A catalogue of resources identified by stable, human-readable string IDs.
##
## Each entry maps a string ID (e.g. [code]&"skeleton"[/code]) to a resource UID. At runtime,
## [Registry] provides lookup, loading, and optional property-index queries — without ever loading
## resources you didn't ask for.[br][br]
##
## Entries are managed through the YARD editor tab and stored in a [code].tres[/code] file.
## The registry is read-only at runtime.
##
## [codeblock]
## const ENEMIES: Registry = preload("res://data/enemy_registry.tres")
## const WEAPONS: Registry = preload("res://data/weapon_registry.tres")
##
## # Load a single entry
## var skeleton: Enemy = ENEMIES.load_entry(&"skeleton")
##
## # Query the property index (baked in the editor)
## var legendaries := WEAPONS.filter(&"rarity", Rarity.LEGENDARY)
## var result := ENEMIES.where({
##     &"weapon.rarity": Rarity.LEGENDARY,  # dot notation for subresources
##     &"level": func(v): return v >= 10,
## })
## [/codeblock][br]
##
## [b]See also:[/b] [Resource], [ResourceLoader]

## Constant to be used with [annotation @GDScript.@export_custom] instead of a [enum PropertyHint] value.
## Enables a dropdown in the inspector for any [StringName], [String], [Array][lb]StringName[rb] or
## [Array][lb]String[rb] property, populated with the string IDs of a [Registry].
## [br][br]
## The hint string accepts up to three comma-separated values:
## [br] • [b]registry path[/b] (required): [code]res://[/code] or [code]uid://[/code] path to the registry
## [br] • [b]show_empty[/b] (optional, default [code]false[/code]): adds a [code]<empty>[/code] option mapping to an empty string
## [br] • [b]allow_duplicates[/b] (optional, default [code]true[/code]): allows the same ID to appear multiple times in an
## [Array][lb]StringName[rb] or
## [Array][lb]String[rb]
## [codeblock]
## @export_custom(Registry.PROPERTY_HINT_CUSTOM, "res://data/item_registry.tres") var item: StringName
## @export_custom(Registry.PROPERTY_HINT_CUSTOM, "res://data/item_registry.tres,true") var item_or_empty: StringName
## @export_custom(Registry.PROPERTY_HINT_CUSTOM, "res://data/item_registry.tres,true,false") var unique_items: Array[StringName]
## [/codeblock]
const PROPERTY_HINT_CUSTOM: int = 1024

const _REGISTRY_FORMAT_VERSION: int = 2

@export_storage var _version: int = 0
@export_storage var _class_restriction: StringName = &""
@export_storage var _scan_directory: String = ""
@export_storage var _recursive_scan: bool = false
@export_storage var _scan_auto: bool = true
@export_storage var _scan_remove: bool = true
@export_storage var _scan_regex_include: String = ""
@export_storage var _scan_regex_exclude: String = ""
# V2 Settings - a real migration is needed here to translate from V1 to V2 without storing redundant data
#@export_storage var _version: int = 0
#@export_storage var _scan_auto: bool = true
#@export_storage var _scan_remove: bool = true
# Holds both default + override rulesets. Overridden rulesets only need to define their non-default values.
@export_storage var _scan_rulesets: Array[Dictionary]

# Bidirectional map. Populated by RegistryIO in the editor, read-only at runtime.
@export_storage var _uids_to_string_ids: Dictionary[StringName, StringName]
@export_storage var _string_ids_to_uids: Dictionary[StringName, StringName]
# Baked property index: property -> value -> set of resources string IDs.
@export_storage var _property_index: Dictionary[StringName, Dictionary] = { }


func _init() -> void:
	if not Engine.is_editor_hint():
		_uids_to_string_ids.make_read_only()
		_string_ids_to_uids.make_read_only()


## Returns the number of entries in the registry. Empty registries always return [code]0[/code].
## See also [method is_empty].
func size() -> int:
	return _uids_to_string_ids.size()


## Returns [code]true[/code] if the registry contains no entries.
## See also [method size].
func is_empty() -> bool:
	return _uids_to_string_ids.is_empty()


## Returns [code]true[/code] if [param property] has been baked into the property index.[br][br]
##
## Use this to guard calls to [method filter] and [method where].
## when indexing of a given property is not guaranteed.
func is_property_indexed(property: StringName) -> bool:
	return _property_index.has(property)


## Returns [code]true[/code] if the given [param id] exists in the registry.[br][br]
##
## The [param id] may be either a string ID (for example, [code]&"enemy_skeleton"[/code])
## or a UID (for example, [code]&"uid://dqtv77mng5dyh"[/code]).
func has(id: StringName) -> bool:
	return get_uid(id) != &""


## Returns [code]true[/code] if the given UID is present in the registry.
##
## The [param uid] must start with [code]uid://[/code].
func has_uid(uid: StringName) -> bool:
	return _uids_to_string_ids.has(uid)


## Returns [code]true[/code] if the given string ID is present in the registry.
func has_string_id(string_id: StringName) -> bool:
	return _string_ids_to_uids.has(string_id)


## Returns an [Array] of all registered UIDs.
##
## Each entry is a [StringName] in the form [code]&"uid://..."[/code].
func get_all_uids() -> Array[StringName]:
	return _uids_to_string_ids.keys()


## Returns an [Array] of all registered string IDs.
func get_all_string_ids() -> Array[StringName]:
	return _string_ids_to_uids.keys()


## Resolves any identifier (string ID or UID) to its UID form.[br][br]
##
## If [param id] is already a registered UID, it is returned unchanged.
## If [param id] is a registered string ID, returns the corresponding UID.
## Returns an empty [StringName] when [param id] cannot be resolved.
func get_uid(id: StringName) -> StringName:
	if _uids_to_string_ids.has(id):
		return id
	return _string_ids_to_uids.get(id, &"")


## Resolves any identifier (string ID or UID) to its string ID form.[br][br]
##
## If [param id] is already a registered string ID, it is returned unchanged.
## If [param id] is a registered UID, returns the corresponding string ID.
## Returns an empty [StringName] when [param id] cannot be resolved.
func get_string_id(id: StringName) -> StringName:
	if _string_ids_to_uids.has(id):
		return id
	return _uids_to_string_ids.get(id, &"")


## Returns the string ID of a loaded [Resource]. Returns an empty [StringName]
## if [param res] is [code]null[/code], has no file path, or is not present in
## the registry.[br][br]
##
## [b]Warning:[/b] This will not work with resources duplicated via [method Resource.duplicate],
## as duplicated resources have an empty [member Resource.resource_path].
func get_string_id_of(res: Resource) -> StringName:
	if not res or res.resource_path.is_empty():
		return &""
	var uid := ResourceUID.path_to_uid(res.resource_path)
	return _uids_to_string_ids.get(StringName(uid), &"")


## Returns an [Array] of all properties that have been baked into the property index.[br][br]
##
## Each entry in the returned array is a [StringName] corresponding to a property key
## that can be queried using [method filter] or [method where].[br][br]
##
## Use this method to inspect which properties are available for fast lookup at runtime,
## without loading the underlying resources.
func get_indexed_properties() -> Array[StringName]:
	return _property_index.keys()


## Loads the resource associated with [param id] (string ID or UID) and returns it.
## Returns [code]null[/code] if the entry does not exist or cannot be loaded.[br][br]
##
## [param type_hint] and [param cache_mode] are passed down to
## [method ResourceLoader.load].
func load_entry(
		id: StringName,
		type_hint: String = "",
		cache_mode: ResourceLoader.CacheMode = ResourceLoader.CACHE_MODE_REUSE,
) -> Resource:
	var uid := get_uid(id)
	if uid == &"" or not ResourceLoader.exists(uid):
		return null
	else:
		return ResourceLoader.load(uid, type_hint, cache_mode)


## Loads all registered resources in a blocking manner. Returns a dictionary
## mapping string IDs to their loaded [Resource] instances.
## Missing or invalid entries are skipped.[br][br]
##
## [param type_hint] and [param cache_mode] are passed down to
## [method ResourceLoader.load].
func load_all_blocking(
		type_hint: String = "",
		cache_mode: ResourceLoader.CacheMode = ResourceLoader.CACHE_MODE_REUSE,
) -> Dictionary[StringName, Resource]:
	var dict: Dictionary[StringName, Resource] = { }

	for uid in get_all_uids():
		if not uid == &"" and ResourceLoader.exists(uid):
			dict[_uids_to_string_ids[uid]] = ResourceLoader.load(
				uid,
				type_hint,
				cache_mode,
			)

	return dict


## Requests threaded loading for all entries and returns a [Registry.RegistryLoadTracker].
## The returned tracker can be used to monitor progress, inspect statuses,
## and retrieve loaded resources as they become available.[br][br]
## See also [method ResourceLoader.load_threaded_request].
func load_all_threaded_request(
		type_hint: String = "",
		use_sub_threads: bool = false,
		cache_mode := ResourceLoader.CACHE_MODE_REUSE,
) -> RegistryLoadTracker:
	var tracker := RegistryLoadTracker.new()

	for string_id: StringName in get_all_string_ids():
		var uid := get_uid(string_id)
		tracker.__uids[string_id] = uid
		tracker.__resources[string_id] = null
		var err := ResourceLoader.load_threaded_request(uid, type_hint, use_sub_threads, cache_mode)
		if err == OK:
			tracker.__requested[string_id] = true
			tracker.__status[string_id] = ResourceLoader.THREAD_LOAD_IN_PROGRESS
		else:
			tracker.__requested[string_id] = false
			tracker.__status[string_id] = ResourceLoader.THREAD_LOAD_INVALID_RESOURCE

	return tracker


## Returns the string IDs of all entries whose [param property] matches [param criterion].[br][br]
##
## [param criterion] is either an exact value ([Variant]) or a [Callable] predicate
## receiving the property value and returning a [bool].
## Requires the property index to have been baked for [param property].
## Returns an empty array if the property is not indexed or no entry matches.
## [codeblock]
## var legendaries := weapon_registry.filter(&"rarity", Rarity.LEGENDARY)
## var high_level := weapon_registry.filter(&"level", func(v): return v >= 10)
## var rare_or_epic := weapon_registry.filter(&"rarity", func(v): return v in [Rarity.RARE, Rarity.EPIC])
## [/codeblock]
## See also [method where].
func filter(property: StringName, criterion: Variant) -> Array[StringName]:
	if not _property_index.has(property):
		return []
	if criterion is Callable:
		var result: Array[StringName] = []
		for value: Variant in _property_index[property]:
			if criterion.call(value):
				for string_id: StringName in _property_index[property][value]:
					result.append(string_id)
		return result
	else:
		var value_map: Dictionary = _property_index[property]
		if not value_map.has(criterion):
			return []
		var result: Array[StringName] = []
		result.assign(value_map[criterion].keys())
		return result


## Returns the string IDs of all entries whose [param property] satisfies [param predicate].[br][br]
##
## [param predicate] receives the property value and must return a [bool].
## Requires the property index to have been baked for [param property].
## Returns an empty array if the property is not indexed or no value matches the predicate.
## [codeblock]
## var high_level := weapon_registry.filter_by(&"level", func(v): return v >= 10)
## var rare_or_epic := weapon_registry.filter_by(&"rarity", func(v): return v in [Rarity.RARE, Rarity.EPIC])
## [/codeblock]
## @deprecated: Use [method filter] instead.
func filter_by(property: StringName, predicate: Callable) -> Array[StringName]:
	var result: Array[StringName] = []
	if not _property_index.has(property):
		return result
	for value: Variant in _property_index[property]:
		if predicate.call(value):
			for string_id: StringName in _property_index[property][value]:
				result.append(string_id)
	return result


## Returns the string IDs of all entries whose [param property] equals [param value].[br][br]
##
## Requires the property index to have been baked for [param property].
## Returns an empty array if the property is not indexed or no entry has that value.
## [codeblock]
## var legendaries := weapon_registry.filter_by_value(&"rarity", Rarity.LEGENDARY)
## [/codeblock]
## @deprecated: Use [method filter] instead.
func filter_by_value(property: StringName, value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if not _property_index.has(property):
		return result
	var value_map: Dictionary = _property_index[property]
	if not value_map.has(value):
		return result
	result.assign(value_map[value].keys())
	return result


## Returns the string IDs of all entries matching all [param criteria] (AND logic).[br][br]
##
## [param criteria] is a [Dictionary] mapping property names to their expected values.
## Requires the property index to have been baked for each property.
## Returns an empty array if any property is not indexed or if the intersection yields no results.
## [codeblock]
## var perfect_armors := armor_registry.filter_by_values({&"defense": 100, &"weight": 0})
## var legendary_swords := weapon_registry.filter_by_values({&"rarity": Rarity.LEGENDARY, &"type": "sword"})
## [/codeblock]
## @deprecated: Use [method where] instead.
func filter_by_values(criteria: Dictionary[StringName, Variant]) -> Array[StringName]:
	var result: Array[StringName] = []
	var initialized := false
	for property: StringName in criteria:
		var matches := filter_by_value(property, criteria[property])
		result = matches if not initialized else _intersect(result, matches)
		initialized = true
		if result.is_empty():
			return result
	return result


## Returns the string IDs of all entries matching all [param criteria] (AND logic).[br][br]
##
## Each value in [param criteria] is either an exact [Variant] to match against, or a
## [Callable] predicate receiving the property value and returning a [bool].
## Requires the property index to have been baked for each property.
## Returns an empty array if any property is not indexed or the intersection is empty.
## [codeblock]
## var result := ROOMS.where({
##     &"biome": Biome.FOREST,
##     &"tier": func(t): return t != RoomData.Tier.Boss,
## })
## [/codeblock]
## See also [method filter].
func where(criteria: Dictionary[StringName, Variant]) -> Array[StringName]:
	var result: Array[StringName] = []
	var initialized := false
	for property: StringName in criteria:
		var matches := filter(property, criteria[property])
		result = matches if not initialized else _intersect(result, matches)
		initialized = true
		if result.is_empty():
			return result
	return result


static func _intersect(base: Array[StringName], other: Array[StringName]) -> Array[StringName]:
	var other_set: Dictionary[StringName, bool] = { }
	for id: StringName in other:
		other_set[id] = true
	var result: Array[StringName] = []
	for id: StringName in base:
		if other_set.has(id):
			result.append(id)
	return result


## Loading tracker used with [method Registry.load_all_threaded_request]
##
## Returned by [method Registry.load_all_threaded_request].
## Provides information about asynchronous resource loading.[br][br]
## All its [Dictionary] properties use resources String IDs as keys :[br][br]
##  - [member progress] is the overall load progress ([code]0.0[/code]–[code]1.0[/code]).[br]
##  - [member status] matches an entry string ID to its current [enum ResourceLoader.ThreadLoadStatus].[br]
##  - [member resources] holds loaded [Resource] objects as they become ready.[br]
##  - [member uids] matches an entry string ID to its UID.[br]
##  - [member requested] tells if the entry was successfully requested through [method ResourceLoader.load_threaded_request].[br][br]
##
## [b]Note:[/b] Accessors automatically poll and update internal loading states before returning.
class RegistryLoadTracker extends RefCounted:
	var progress: float:
		get:
			_poll()
			return __progress

	var uids: Dictionary[StringName, StringName]:
		get:
			return __uids.duplicate()

	var requested: Dictionary[StringName, bool]:
		get:
			return __requested.duplicate()

	var status: Dictionary[StringName, ResourceLoader.ThreadLoadStatus]:
		get:
			_poll()
			return __status.duplicate()

	var resources: Dictionary[StringName, Resource]:
		get:
			_poll()
			return __resources.duplicate()

	var __progress: float = 0.0
	var __uids: Dictionary[StringName, StringName]
	var __requested: Dictionary[StringName, bool]
	var __status: Dictionary[StringName, ResourceLoader.ThreadLoadStatus]
	var __resources: Dictionary[StringName, Resource]


	func _poll() -> void:
		var n_res_requested := 0
		var n_res_loaded := 0.0 # allow fractional loading progress
		for uid: String in __uids.values():
			var res_progress := []
			if not __requested[uid]:
				continue
			n_res_requested += 1
			__status[uid] = ResourceLoader.load_threaded_get_status(uid, res_progress)
			n_res_loaded += res_progress[0]
			if (
				__status[uid] == ResourceLoader.THREAD_LOAD_LOADED
				and __resources[uid] == null
			):
				__resources[uid] = ResourceLoader.load_threaded_get(uid)
		__progress = n_res_loaded / n_res_requested
