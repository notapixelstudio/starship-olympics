extends Node2D

export var debug = false

func _ready():
	var children = get_children()
	var index = randi() % len(children)
	var i = 0
	for child in children:
		if debug and child.visible == false:
			# destroy invisible children
			child.queue_free()
		else:
			# destroy all children but one at random
			if index != i:
				child.queue_free()
			else:
				# make sure it is visible
				child.visible = true
		i += 1
		
