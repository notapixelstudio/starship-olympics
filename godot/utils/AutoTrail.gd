extends Node2D

export var starting_color := Color(1,1,1,0.1)
export var ending_color := Color(1,1,1,0)
export var length := 30
export var width := 90

var trail

# create a new trail each time this node (hence its parent) enters the tree
func _enter_tree():
	trail = Trail2D.new()
	trail.gradient = Gradient.new()
	trail.gradient.set_color(0, ending_color)
	trail.gradient.set_color(1, starting_color)
	trail.trail_length = length
	trail.width = width
	add_child(trail)
	
# drop the trail onto the parent's parent on exiting the tree
func _exit_tree():
	remove_child(trail)
	get_parent().get_parent().add_child(trail)
	trail.disappear()
