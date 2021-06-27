extends Node2D

func _ready():
	# destroy all children but one at random
	var children = get_children()
	var index = randi() % len(children)
	var i = 0
	for child in children:
		if index != i:
			child.queue_free()
		else:
			# make sure it is visible
			child.visible = true
		i += 1
		
