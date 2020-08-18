extends Node2D

export var grid_color : Color = Color.gray
export var dots_color : Color = Color.gray
export var cell_size := Vector2.ONE * 100
export var enabled : bool = true

enum TYPE { square, triangular, hexagonal }
export(TYPE) var type = TYPE.square

export var show_dots = false
export var show_lines = true

var active_points = []
var grid = []
var lines = []
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
	
	var lines_amount # populate the array of lines according to tiling type
	if type == TYPE.square:
		lines_amount = h_cells + v_cells
	elif type == TYPE.triangular:
		lines_amount = h_cells + h_cells + v_cells
	elif type == TYPE.hexagonal:
		lines_amount = h_cells + h_cells + h_cells*v_cells
	
	# Temporarily store the cells so we can set their neighbors that they'll draw to
	grid.resize(v_cells)
	for y in v_cells:
		grid[y] = []
		grid[y].resize(h_cells)
		for x in h_cells:
			if type == TYPE.hexagonal and check_no_hex(x, y):
				continue
			var coords = cell_size * Vector2(x+(0 if type == TYPE.square else 0.5*(y%2)), y) + position
			grid[y][x] = Point.new(coords, Vector2(x, y), show_dots, position, dots_color)
			if show_dots:
				add_child(grid[y][x].dot)
	
	if show_lines:
		lines.resize(lines_amount)
		# Init grid lines
		# Vertical lines (squiggly if triangular or hexagonal)
		for x in h_cells:
			if type == TYPE.hexagonal and x % 3 != 2:
				continue
			var line = new_line()
			for y in v_cells:
				line.add_point(grid[y][x].position)
			lines[x] = line
			
		# Additional squiggly vertical lines
		if type == TYPE.triangular or type == TYPE.hexagonal:
			for x in range(1,h_cells):
				if type == TYPE.hexagonal and x % 3 != 1:
					continue
				var line = new_line()
				for y in v_cells:
					line.add_point(grid[y][x-y%2].position)
				lines[h_cells + x] = line
			
		# Horizontal lines (full length)
		if type == TYPE.triangular or type == TYPE.square:
			for y in v_cells:
				var line = new_line()
				for x in h_cells:
					line.add_point(grid[y][x].position)
				lines[h_cells + (0 if type == TYPE.square else h_cells) + y] = line
				
		# Horizontal segments
		if type == TYPE.hexagonal:
			for x in range(1,h_cells):
				for y in v_cells:
					if check_no_hex(x, y) or check_no_hex(x+1, y):
						continue
					var line = new_line()
					line.add_point(grid[y][x].position)
					line.add_point(grid[y][x+1].position)
					lines[h_cells + h_cells + (x-1)*v_cells+y] = line
					
		
func check_no_hex(x, y):
	return (x+(y+1)%2) % 3 == 1
	
func new_line():
	var line = Line2D.new()
	line.position = -position
	line.width = 5
	line.default_color = grid_color
	line.light_mask |= 1 << 1
	add_child(line)
	return line
	
const MULTIPLIER = 0.25
var count_frame = 0

func _process(delta):
	count_frame += 1
	if count_frame % 2:
		return
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
		# Update lines
		if show_lines:
			var selected_line = lines[point.index.x]
			if selected_line:
				selected_line.set_point_position(point.index.y, point.position)
			if type == TYPE.square:
				lines[h_cells + point.index.y].set_point_position(point.index.x, point.position)
			
			if type == TYPE.triangular or type == TYPE.hexagonal:
				var squiggly_y = point.index.x+(int(point.index.y)%2)
				if squiggly_y < h_cells:
					selected_line = lines[h_cells + squiggly_y]
					if selected_line:
						selected_line.set_point_position(point.index.y, point.position)
						
			if type == TYPE.triangular:
				selected_line = lines[h_cells + h_cells + point.index.y]
				if selected_line:
					selected_line.set_point_position(point.index.x, point.position)
					
			if type == TYPE.hexagonal:
				selected_line = lines[h_cells + h_cells + (point.index.x-1)*v_cells + point.index.y]
				if selected_line:
					selected_line.default_color = Color(1,1,1,1)
					if (int(point.index.x-1)) % 3 == 0:
						selected_line.set_point_position(0, point.position)
					#elif (int(point.index.x-1)+(int(point.index.y)%2)) % 3 == 1:
					#	selected_line.set_point_position(1, point.position)

class Point:
	var velocity := Vector2.ZERO
	var position : Vector2
	var anchor : Vector2
	var index : Vector2
	var dot : Line2D
	var show_dots
	
	func _init(position, index, show_dots, global_position, dots_color):
		self.position = position
		self.index = index
		self.show_dots = show_dots
		anchor = position
		
		if show_dots:
			self.dot = Line2D.new()
			self.dot.width = 10.0
			self.dot.joint_mode = Line2D.LINE_JOINT_ROUND
			self.dot.begin_cap_mode = Line2D.LINE_CAP_ROUND
			self.dot.end_cap_mode = Line2D.LINE_CAP_ROUND
			self.dot.light_mask |= 1 << 1
			self.dot.default_color = dots_color
			self.dot.position = position
			self.dot.points = PoolVector2Array([-global_position, -global_position+Vector2(0.1,0.1)])
			
			# debug
			#var label = Label.new()
			#label.margin_left = -global_position.x
			#label.margin_top = -global_position.y
			#label.text = '(' + str(index.x) + ', ' + str(index.y) + ')'
			#self.dot.add_child(label)
			
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
