extends Node2D

const GridPoint = preload("res://GridPoint.tscn")

export var grid_color : Color = Color.gray
export (int) var h_cells := 32
export (int) var v_cells := 32
export var cell_size := Vector2.ONE * 16

var active_points = []
var grid = []
var lines = []

func _ready():
	position = -(cell_size * Vector2(h_cells, v_cells)) / 2.0
	_init_grid()

# Iterates through x and y axis, adding cells for each iteration
func _init_grid():
	# Temporarily store the cells so we can set their neighbors that they'll draw to
	grid.resize(v_cells)
	for y in v_cells:
		grid[y] = []
		grid[y].resize(h_cells)
		for x in h_cells:
			grid[y][x] = Point.new(cell_size * Vector2(x, y) + position, Vector2(x, y))
	lines.resize(h_cells + v_cells)
	# Init grid lines
	# Vertical Rows
	for x in h_cells:
		var line = Line2D.new()
		line.position = -position
		add_child(line)
		line.width = 1
		line.default_color = grid_color
		line.light_mask |= 1 << 1
		for y in v_cells:
			line.add_point(grid[y][x].position)
		lines[x] = line
	for y in v_cells:
		var line = Line2D.new()
		line.position = -position
		add_child(line)
		line.width = 1
		line.default_color = grid_color
		line.light_mask |= 1 << 1
		for x in h_cells:
			line.add_point(grid[y][x].position)
		lines[h_cells + y] = line

func _process(delta):
	
	var gravity_wells = get_tree().get_nodes_in_group("gravity_wells")
	for well in gravity_wells:
		if abs(well.gravity) <= 1: continue
		var index = (well.position - position).snapped(cell_size) / cell_size
		var radius = well.influence_radius / cell_size.x + 1
		for y in range(index.y - radius, index.y + radius):
			for x in range(index.x - radius, index.x + radius):
				if x <= 0 || x >= h_cells - 1 || y <= 0 || y >= v_cells - 1: continue
				var point = grid[y][x]
				if active_points.has(point): continue
				var dist = (well.position - point.position).length()
				if dist < well.influence_radius:
					active_points.append(point)
	for point in active_points:
		point.process(delta, gravity_wells)
		if point.is_at_rest():
			point.rest()
			active_points.erase(point)
		# Update lines
		lines[point.index.x].set_point_position(point.index.y, point.position)
		lines[h_cells + point.index.y].set_point_position(point.index.x, point.position)

class Point:
	var velocity := Vector2.ZERO
	var position : Vector2
	var anchor : Vector2
	var index : Vector2
	
	func _init(position, index):
		self.position = position
		self.index = index
		anchor = position
	
	func process(delta, gravity_wells):
		# elastic velocity
		var diff = anchor - position
		var desired_velocity = diff * 24
		velocity = velocity.linear_interpolate(desired_velocity, 0.2)
		
		# gravity velocity
		for well in gravity_wells:
			var well_diff = well.global_position - position
			if well_diff.length() < well.influence_radius:
				velocity += well_diff * quantum_entanglement(well_diff.length(), well.influence_radius) * well.gravity * delta
		
		
		position += velocity * delta
	
	func quantum_entanglement(x, influence_rad):
		return pow(x-influence_rad, 2)/pow(influence_rad, 2)
		
	func rest():
		position = anchor
		velocity = Vector2.ZERO
	
	func is_at_rest():
		return (anchor - position).length() < 1 && velocity.length() < 1