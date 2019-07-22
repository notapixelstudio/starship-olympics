extends Node2D

var x_neighbor = null setget set_x_neighbor
var y_neighbor = null setget set_y_neighbor

var x_line
var y_line
var line_color = Color.blue

onready var anchor = global_position # Resting position
var velocity := Vector2.ZERO

func _process(delta):
	var diff = anchor - global_position
	var desired_velocity = diff * 8
	velocity = velocity.linear_interpolate(desired_velocity, 0.2) # Push velocity towards anchor
	# Iterate through all gravity wells
	for well in get_tree().get_nodes_in_group("gravity_wells"):
		var well_diff = well.global_position - global_position
		# If point is within range to be affected by the gravity well
		if (well_diff).length() < well.influence_radius:
			# 0 - 1 value determine how close point is to gravity well, 1 being closest
			var distance_factor = 1 - well_diff.length() / well.influence_radius
			# Push velocity according to gravity well's influence
			velocity += (well_diff * distance_factor) * well.gravity * delta
	global_position += velocity * delta
	_update_lines()

# Adjusts lines to point to their neighbor
func _update_lines():
	if x_neighbor != null:
		x_line.set_point_position(1, x_neighbor.global_position - global_position)
	if y_neighbor != null:
		y_line.set_point_position(1, y_neighbor.global_position - global_position)

func set_x_neighbor(value):
	x_neighbor = value
	if value != null:
		x_line = _create_line(value)

func set_y_neighbor(value):
	y_neighbor = value
	if value != null:
		y_line = _create_line(value)

# Initiates a line to point to the neighbor
func _create_line(neighbor : Node2D):
	var line = Line2D.new()
	add_child(line)
	line.add_point(Vector2.ZERO)
	line.add_point(neighbor.global_position - global_position)
	line.width = 1
	line.default_color = line_color
	line.show_behind_parent = true
	return line