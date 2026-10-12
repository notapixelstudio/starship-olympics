class_name Familiar extends Node2D
## Shared owner and item context for a familiar's behavior children.

var owner_ship: Ship
var definition: PackedScene
var copy_index := 0
var copy_count := 1
var previous_same_scene: Familiar

func configure(owner: Ship, scene: PackedScene, index := 0, count := 1, previous: Familiar = null) -> void:
	owner_ship = owner
	definition = scene
	copy_index = index
	copy_count = count
	previous_same_scene = previous
	modulate = owner.get_color()
	ActorBehavior.bind_children(self, owner)
	for child in get_children():
		if child is Weapon:
			child.host = owner
