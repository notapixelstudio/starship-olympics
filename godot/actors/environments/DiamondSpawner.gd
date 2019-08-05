extends Node2D

class_name CollectableSpawner
export var diamond_scene: PackedScene
export var wave: int

var children_ = []

func _ready():
	for element in get_children():
		children_.append(element)
		remove_child(element)

func spawn():
	var collectables = []
	for element in children_:
		add_child(element.duplicate())
		
		#var diamond = diamond_scene.instance()
		# offset of the spawner
		#diamond.position = element.position + position
		#collectables.append(diamond)
	#return collectables
	
func remove(element):
	remove_child(element)
	yield(get_tree().create_timer(1), "timeout")
	element.queue_free()