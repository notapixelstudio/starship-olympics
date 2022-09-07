extends Node2D

export (Array, PackedScene) var variant_scenes = []
export var debug_variant_index := -1
export var automirror := false

func _ready():
	if len(variant_scenes) <= 0:
		return
		
	var index : int = randi() % len(variant_scenes)
	
	if global.the_match.get_minigame() and global.the_match.get_minigame().is_first_time_started():
		index = 0
		
	if debug_variant_index >= 0:
		index = debug_variant_index
		
	var variant = variant_scenes[index].instance()
	if automirror and randi()%2:
		# mirror all content horizontally
		for child in variant.get_children():
			child.position.x = -child.position.x
	add_child(variant)
	
