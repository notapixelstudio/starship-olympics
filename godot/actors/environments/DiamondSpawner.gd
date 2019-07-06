extends Node2D

class_name CollectableSpawner
export var diamond_scene: PackedScene
export var wave: int

var arena

func initialize(_arena):
	arena = _arena

func spawn() -> Array:
	var collectables = []
	for element in get_children():
		assert(element is Node2D)
		var diamond = diamond_scene.instance()
		# offset of the spawner
		diamond.position = element.position + position
		collectables.append(diamond)
	return collectables
		