extends Node

export var too_many_players := 4

func _ready():
	yield(get_tree(), "idle_frame")
	if global.the_game.get_number_of_players() >= too_many_players:
		for c in get_children():
			if c is Wall:
				c.queue_free()
				#c.set_type(Wall.TYPE.ghost)
