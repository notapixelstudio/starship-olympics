tool

extends StaticBody2D
class_name Wall

export (bool) var hollow setget set_hollow

export (int) var offset setget set_offset
export (int) var elongation setget set_elongation

enum TYPE { solid, hostile, ghost, decoration }
export(TYPE) var type = TYPE.solid setget set_type

export var hide_line : bool = false setget set_hide_line
export var hide_grid : bool = false setget set_hide_grid

export var grid_color : Color = Color(1,1,1,0.33) setget set_grid_color
export var grid_rotation : float = 0 setget set_grid_rotation

export var fill_color : Color = Color('#454545') setget set_fill_color

const glow_strength = 1.08

var cshapes = []

func set_hollow(value):
	hollow = value
	refresh()
	
func set_offset(value):
	offset = value
	refresh()
	
func set_elongation(value):
	elongation = value
	refresh()
	
func set_type(value):
	type = value
	refresh()
	
func set_hide_line(value):
	hide_line = value
	refresh()
	
func set_hide_grid(value):
	hide_grid = value
	refresh()
	
func set_grid_color(value):
	grid_color = value
	refresh()
	
func set_grid_rotation(value):
	grid_rotation = value
	refresh()
	
func set_fill_color(value):
	fill_color = value
	refresh()
	
func _ready():
	var gshape
	for node in get_children():
		if node is GShape:
			gshape = node
	# extents.size = gshape.get_extents()
	refresh()

func get_rect_extents():
	var gshape
	for node in get_children():
		if node is GShape:
			gshape = node
			break
	var size = gshape.get_extents()
	return Rect2(-1.0 * size / 2 , size)

func remove_old_shapes():
	for child in get_children():
		if child is CollisionShape2D:
			remove_child(child)
			child.queue_free()
	
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func _get_configuration_warning():
	if not get_gshape():
		return 'Please provide a GShape as child node to define the geometry.\n'
	return ''
	
func refresh():
	remove_old_shapes()
	
	var gshape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed', self, 'refresh'):
		gshape.connect('changed', self, 'refresh')
		
	var points = gshape.to_PoolVector2Array()
	
	if not type == TYPE.ghost and not type == TYPE.decoration:
		if hollow:
			for i in range(len(points)):
				var cshape = CollisionShape2D.new()
				var shape = ConvexPolygonShape2D.new()
				var a = points[i]
				var b = points[(i+1) % len(points)]
				var elo = (b-a).normalized()*elongation
				shape.set_points(PoolVector2Array([a-elo,a+a.normalized()*offset-elo,b+b.normalized()*offset+elo,b+elo]))
				cshape.set_shape(shape)
				add_child(cshape)
		else:
			var cshape = CollisionShape2D.new()
			var shape = ConvexPolygonShape2D.new()
			shape.set_points(points)
			cshape.set_shape(shape)
			add_child(cshape)
			
	$Polygon2D.set_polygon(points)
	$Grid.set_polygon(points)
	
	$Polygon2D.color = fill_color
	
	$Polygon2D.visible = not hollow and not type == TYPE.ghost and not type == TYPE.decoration
	$Grid.visible = hollow and not type == TYPE.ghost and not type == TYPE.decoration and not hide_grid
	$line.visible = not hide_line
	
	$Grid.set_texture_rotation(rotation + deg2rad(grid_rotation))
	
	# close the line with a seamless join
	var ps = PoolVector2Array(points)
	ps.remove(0)
	var p = points[0]+(points[1]-points[0])*0.5
	$line.points = PoolVector2Array([p]) + ps + PoolVector2Array([points[0], p])
	
	# wall types
	var color
	if type == TYPE.hostile:
		color = GlowColor.new(Color(1,0,0,1), glow_strength).color
		$Polygon2D.modulate = color
		$line.modulate = color
		$Entity/Deadly.enabled = true
		$Entity/Trigger.enabled = true
	elif type == TYPE.solid:
		color = GlowColor.new(Color(1,1,1,1), glow_strength).color
		$Polygon2D.modulate = color
		$line.modulate = color
		$Entity/Deadly.enabled = false
		$Entity/Trigger.enabled = false
	elif type == TYPE.ghost:
		color = GlowColor.new(Color(0.2,0.7,1,0.8), glow_strength).color
		$line.modulate = color
	elif type == TYPE.decoration:
		color = GlowColor.new(Color(1,1,1,1), glow_strength).color
		$line.modulate = color
		
	# workaround for losing texture mode
	$line.texture_mode = Line2D.LINE_TEXTURE_TILE
	
	# grid color
	$Grid.modulate = grid_color
	
func animate(animation_name: String):
	if $AnimationPlayer:
		if $AnimationPlayer.assigned_animation != animation_name:
			$AnimationPlayer.play(animation_name)
