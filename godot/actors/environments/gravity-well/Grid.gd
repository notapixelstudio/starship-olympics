extends Node2D

export var grid_color : Color = Color.gray
export var dots_color : Color = Color.gray
export var cell_size := Vector2.ONE * 100
export var enabled : bool = true

enum TYPE { square, triangular, hexagonal, horizontal, vertical, squiggly, rhomboidal }
export(TYPE) var type = TYPE.square

export var show_dots = false
export var show_lines = true

var active_points = []
var grid = []
var v_cells
var h_cells

const max_velocity = 4000

# Iterates through x and y axis, adding cells for each iteration
func init_grid(arena_size: Vector2):
	set_process(enabled)
	if not enabled:
		return
	
	v_cells = ceil(arena_size.y/cell_size.y) + 1
	h_cells = ceil(arena_size.x/cell_size.x) + 1 
	position = -cell_size * Vector2(h_cells-1, v_cells-1)/2.0
	
	# Temporarily store the cells so we can set their neighbors that they'll draw to
	grid.resize(v_cells)
	for y in v_cells:
		grid[y] = []
		grid[y].resize(h_cells)
		for x in h_cells:
			if type == TYPE.hexagonal and not check_hex(x, y):
				continue
			var squiggly = type == TYPE.triangular or type == TYPE.hexagonal or type == TYPE.squiggly or type == TYPE.rhomboidal
			var coords = cell_size * Vector2(x+(0 if not squiggly else 0.5*(y%2)), y) + position
			grid[y][x] = Point.new(coords, Vector2(x, y))
		
func _draw():
	if show_lines:
		if type == TYPE.square:
			for x in h_cells-1:
				for y in v_cells-1:
					draw_line(-position+grid[y][x].position, -position+grid[y][x+1].position, grid_color, 5.0)
					draw_line(-position+grid[y][x].position, -position+grid[y+1][x].position, grid_color, 5.0)
		elif type == TYPE.triangular:
			for x in h_cells-1:
				for y in v_cells-1:
					draw_line(-position+grid[y][x].position, -position+grid[y][x+1].position, grid_color, 5.0)
					draw_line(-position+grid[y][x].position, -position+grid[y+1][x+y%2].position, grid_color, 5.0)
					draw_line(-position+grid[y][x+1].position, -position+grid[y+1][x+y%2].position, grid_color, 5.0)
		elif type == TYPE.hexagonal:
			for x in h_cells-1:
				for y in v_cells-1:
					if check_hex(x, y) and check_hex(x+1, y):
						draw_line(-position+grid[y][x].position, -position+grid[y][x+1].position, grid_color, 5.0)
					if check_hex(x, y) and check_hex(x+y%2, y+1):
						draw_line(-position+grid[y][x].position, -position+grid[y+1][x+y%2].position, grid_color, 5.0)
					if check_hex(x+1, y) and check_hex(x+y%2, y+1):
						draw_line(-position+grid[y][x+1].position, -position+grid[y+1][x+y%2].position, grid_color, 5.0)
		elif type == TYPE.horizontal:
			for x in h_cells-1:
				for y in v_cells-1:
					draw_line(-position+grid[y][x].position, -position+grid[y][x+1].position, grid_color, 5.0)
		elif type == TYPE.vertical or type == TYPE.squiggly:
			for x in h_cells-1:
				for y in v_cells-1:
					draw_line(-position+grid[y][x].position, -position+grid[y+1][x].position, grid_color, 5.0)
		elif type == TYPE.rhomboidal:
			for x in h_cells-1:
				for y in v_cells-1:
					draw_line(-position+grid[y][x].position, -position+grid[y+1][x+y%2].position, grid_color, 5.0)
					draw_line(-position+grid[y][x+1].position, -position+grid[y+1][x+y%2].position, grid_color, 5.0)
					
	if show_dots:
		for x in h_cells-1:
			for y in v_cells-1:
				if grid[y][x]:
					draw_line(-position+grid[y][x].position+Vector2(0,5), -position+grid[y][x].position+Vector2(0,-5), dots_color, 10.0)
	
func check_hex(x, y):
	return (x+(y+1)%2) % 3 != 1
	
const MULTIPLIER = 0.25
var count_frame = 0

func _process(delta):
	var gravity_wells = get_tree().get_nodes_in_group("gravity_wells")
	for well in gravity_wells:
		if abs(well.get_gravity() * MULTIPLIER) <= 1: continue
		var index = (well.global_position - position).snapped(cell_size) / cell_size
		var radius = well.get_influence_radius() / cell_size.x + 1
		for y in range(index.y - radius, index.y + radius):
			for x in range(index.x - radius, index.x + radius):
				if x <= 0 || x >= h_cells - 1 || y <= 0 || y >= v_cells - 1: continue
				
				# skip missing points
				if not grid[y] or not grid[y][x]:
					continue
				
				var point = grid[y][x]
				if active_points.has(point): continue
				var dist = (well.global_position - point.position).length()
				if dist < well.get_influence_radius():
					active_points.append(point)
	for point in active_points:
		point.process(delta, gravity_wells)
		if point.is_at_rest():
			point.rest()
			active_points.erase(point)
			
	update()
	
class Point:
	var velocity := Vector2.ZERO
	var position : Vector2
	var anchor : Vector2
	var index : Vector2
	var dot : Line2D
	var show_dots
	
	func _init(position, index):
		self.position = position
		self.index = index
		anchor = position
		
	func process(delta, gravity_wells):
		# elastic velocity
		var diff = anchor - position
		var desired_velocity = diff * 24
		velocity = velocity.linear_interpolate(desired_velocity, 0.15)
		
		# gravity velocity
		for well in gravity_wells:
			var well_diff = well.global_position - position
			if well_diff.length() < well.get_influence_radius():
				velocity += well_diff * global.sigmoid(well_diff.length(), well.get_influence_radius()) * well.get_gravity() * MULTIPLIER * delta
		
		velocity = velocity.normalized() * min(velocity.length(), max_velocity)
		
		position += velocity * delta
		
		# update dots
		if self.show_dots:
			self.dot.position = position
		
	func rest():
		position = anchor
		velocity = Vector2.ZERO
	
	func is_at_rest():
		return (anchor - position).length() < 1 && velocity.length() < 1
