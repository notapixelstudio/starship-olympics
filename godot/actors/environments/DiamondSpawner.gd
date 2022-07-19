extends Node2D

tool

class_name SpawnerElement
export var element_scene: PackedScene
export var wave: int

var children_ = []

func _ready():
	if Engine.is_editor_hint():
		var element = element_scene.instance()
		$Sprite.texture = element.get_node("Sprite").texture
	
func spawn():
	var element = element_scene.instance()
	add_child(element)
		#var diamond = diamond_scene.instance()
		# offset of the spawner
		#diamond.position = element.position + position
		#collectables.append(diamond)
	#return collectables
	
func remove(element):
	remove_child(element)
	yield(get_tree().create_timer(1), "timeout")
	element.queue_free()
