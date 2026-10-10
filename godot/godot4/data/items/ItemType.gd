@tool
class_name ItemType extends Resource
## What an item is and does: one file per effect. What it does is written in the arena ItemManager, keyed by [member id].
## Variants (how long it lasts, glass) are [Item]s pointing here.

const ITEMS_DIR := "res://godot4/data/items/"
const PICKUPS_DIR := "res://godot4/elements/collectables/items/"
const COLLECTABLE_SCENE := "res://godot4/elements/collectables/Collectable.tscn"
const PICKUP_TSCN := """[gd_scene format=3]

[ext_resource type="PackedScene" path="%s" id="1_coll"]
[ext_resource type="Resource" path="%s" id="2_item"]

[node name="%s" instance=ExtResource("1_coll")]
item = ExtResource("2_item")
"""

@export var id: StringName
@export var name: String
@export_multiline var description: String = ""

@export_enum(&'general', &'player', &'ship', &'hat', &'ball', &'weapon', &'weapon-back') var slot: String

@export var texture: Texture2D
@export var outline_texture: Texture2D
@export var glow := Color.WHITE
## Shown over the holder's ship while the item is in play; leave empty for no badge.
@export var badge: Texture2D

## Creates an [Item] and a pickup scene for every duration × glass, skipping files that already exist.
@export_tool_button("Generate variants") var _generate := generate_variants


func generate_variants() -> void:
	assert(id != &"" and resource_path != "", "save the ItemType and set its id first")
	DirAccess.make_dir_recursive_absolute(ITEMS_DIR + id)
	DirAccess.make_dir_recursive_absolute(PICKUPS_DIR + id)
	for duration in Item.Duration.values():
		for glass in [false, true]:
			var variant: String = "%s_%s%s" % [id, Item.Duration.find_key(duration).to_lower(), "_glass" if glass else ""]
			var item_path := "%s%s/%s.tres" % [ITEMS_DIR, id, variant]
			if not ResourceLoader.exists(item_path):
				var item := Item.new()
				item.type = self
				item.duration = duration
				item.glass = glass
				ResourceSaver.save(item, item_path)
			var pickup_path := "%s%s/%s.tscn" % [PICKUPS_DIR, id, variant]
			if not ResourceLoader.exists(pickup_path):
				# written as text: PackedScene.pack() flattens the instance instead of inheriting Collectable.tscn
				FileAccess.open(pickup_path, FileAccess.WRITE).store_string(PICKUP_TSCN % [COLLECTABLE_SCENE, item_path, variant.to_pascal_case()])
	if Engine.is_editor_hint():
		Engine.get_singleton("EditorInterface").get_resource_filesystem().scan()
