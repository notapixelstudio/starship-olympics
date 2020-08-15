extends Node2D

class_name MapCell

var neighbours = {}

func set_neighbour(n, dir):
	neighbours[dir] = n
	
signal pressed
func act(cursor):
	emit_signal('pressed', cursor)
	
func _ready():
	add_to_group('mapcell')
	
