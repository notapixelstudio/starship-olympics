extends Node2D

tool

class_name SpawnerElement
export var element_scene: PackedScene
export var wave: int

var children_ = []

func _ready():
	var element = element_scene.instance()
	if Engine.is_editor_hint():
		$Sprite.texture = element.get_node("Sprite").texture
	else:
		$Sprite.queue_free()
		
		
	
func spawn():
	var element = element_scene.instance()
	add_child(element)
		#var diamond = diamond_scene.instance()
		# offset of the spawner
		#diamond.position = element.position + position
		#collectables.append(diamond)
	#return collectables
	
func remove_child(element):
	.remove_child(element)
	element.queue_free()
