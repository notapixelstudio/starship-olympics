extends Node2D

export var debug = false

func _ready():
	var children = get_children()
	
	var index : int
	if global.the_match.get_minigame() and global.the_match.get_minigame().is_first_time_started():
		index = 0
	else:
		index = randi() % len(children)
		
	var i = 0
	for child in children:
		if debug:
			# destroy invisible children
			if child.visible == false:
				child.queue_free()
		else:
			# destroy all children but one at random
			if index != i:
				child.queue_free()
			else:
				# make sure it is visible
				child.visible = true
		i += 1
		
