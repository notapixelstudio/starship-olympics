tool

extends StaticBody2D
class_name Wall

export (bool) var hollow setget set_hollow

export (int) var offset setget set_offset
export (int) var elongation setget set_elongation

enum TYPE { solid, hostile, ghost, decoration, glass }
export(TYPE) var type = TYPE.solid setget set_type

export var hide_line : bool = false setget set_hide_line
export var hide_line_below : bool = false setget set_hide_line_below
export var hide_grid : bool = false setget set_hide_grid

export var line_width = 48 setget set_line_width

export var solid_line_color = Color8(208, 245, 295, 255) setget set_solid_line_color
export var line_texture : Texture setget set_line_texture

export var grid_color : Color = Color(1,1,1,0.33) setget set_grid_color
export var grid_rotation : float = 0 setget set_grid_rotation

export var platform = false
export(String, 'both', 'above', 'below') var under = 'both' setget set_under

const texture_glass = preload('res://assets/sprites/stripes.png')

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
	
func set_hide_line_below(value):
	hide_line_below = value
	refresh()
	
func set_hide_grid(value):
	hide_grid = value
	refresh()
	
func set_line_width(value):
	line_width = value
	refresh()
	
func set_solid_line_color(v):
	solid_line_color = v
	refresh()
	
func set_line_texture(v):
	line_texture = v
	refresh()
	
func set_grid_color(value):
	grid_color = value
	refresh()
	
func set_grid_rotation(value):
	grid_rotation = value
	refresh()
	
func set_under(value):
	under = value
	set_collision_layer_bit(4, false)
	add_to_group('nostyle')
	
	if under == 'below':
		z_as_relative = false
		z_index = -50
		$line.z_index = -50
		$lineBelow.z_index = -60
		$InnerPolygon2D.visible = false
		set_collision_mask_bit(0, false)
		set_collision_mask_bit(18, true)
		modulate = Color(0.5,0.5,1)
		$Polygon2D.color = Color(0.7,0.7,0.7)
	elif under == 'above':
		z_as_relative = true
		z_index = 0
		$line.z_index = 0
		$lineBelow.z_index = -10
		$InnerPolygon2D.visible = false
		set_collision_mask_bit(0, true)
		set_collision_mask_bit(18, false)
		modulate = Color(1,0.5,0.5)
		$Polygon2D.color = Color(0.7,0.7,0.7)
	elif under == 'both':
		z_as_relative = true
		z_index = 0
		$line.z_index = 0
		$lineBelow.z_index = -10
		$InnerPolygon2D.visible = true
		set_collision_layer_bit(4, true)
		set_collision_mask_bit(0, true)
		set_collision_mask_bit(18, true)
		remove_from_group('nostyle')
		modulate = Color(1,1,1)
		$Polygon2D.color = Color('#4f3f3c')
	
func _ready():
	var gshape
	for node in get_children():
		if node is GShape:
			gshape = node
	# extents.size = gshape.get_extents()
	refresh()
	
	# disable platform area unless this is the OutsideWall (or if platform is true)
	$PlatformArea/CollisionShape2D.disabled = not platform and name != 'OutsideWall'

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
			
	$InnerPolygon2D.visible = not hollow and not(type == TYPE.ghost) and not(type == TYPE.glass) and under == 'both'
	
	$Polygon2D.set_polygon(points)
	$InnerPolygon2D.set_polygon(points)
	$Grid.set_polygon(points)
	
	$Polygon2D.visible = not hollow and not type == TYPE.ghost and not type == TYPE.decoration
	$Grid.visible = hollow and not type == TYPE.ghost and not type == TYPE.decoration and not hide_grid
	$line.visible = not hide_line
	$lineBelow.visible = not hide_line_below
	
	$Grid.set_texture_rotation(rotation + deg2rad(grid_rotation))
	
	# glass pass-through
	set_collision_layer_bit(4, type != TYPE.glass and under == 'both')
	$Polygon2D.self_modulate = Color(1,1,1,0.8) if type == TYPE.glass or under == 'above' else Color(1,1,1,1)
	$Polygon2D.texture = texture_glass if type == TYPE.glass else null
	$Polygon2D.set_texture_rotation(rotation)
	$Entity/CrownDropper.enabled = type == TYPE.glass
	
	# close the line with a seamless join
	var ps = PoolVector2Array(points)
	ps.remove(0)
	var p = points[0]+(points[1]-points[0])*0.5
	$line.points = PoolVector2Array([p]) + ps + PoolVector2Array([points[0], p])
	$lineBelow.points = PoolVector2Array([p]) + ps + PoolVector2Array([points[0], p])
	
	$line.texture = line_texture
	$lineBelow.texture = line_texture
	
	# wall types
	var color
	if type == TYPE.hostile:
		color = GlowColor.new(Color(1,0,0,1), glow_strength).color
		$Polygon2D.modulate = color
		$line.modulate = color
		$lineBelow.modulate = color
		$Entity/Deadly.enabled = true
		$Entity/Trigger.enabled = true
	elif type == TYPE.solid:
		$Polygon2D.modulate = solid_line_color
		$line.modulate = solid_line_color
		$lineBelow.modulate = solid_line_color
		$Entity/Deadly.enabled = false
		$Entity/Trigger.enabled = false
	elif type == TYPE.ghost:
		$line.visible = false
		$lineBelow.self_modulate = Color(1,1,1,1)
		$lineBelow.modulate = Color(0.2,0.4,1,0.2)
	elif type == TYPE.decoration:
		$line.modulate = Color(0.8,0.8,1.09,1)
		$lineBelow.modulate = Color(0.8,0.8,1.09,1)
	elif type == TYPE.glass:
		color = Color(0.4,0.7,1.2,1)
		$Polygon2D.modulate = color
		$line.modulate = color
		$lineBelow.modulate = color
		$lineBelow.self_modulate = Color(1,1,1,0.4)
		$Entity/Deadly.enabled = false
		$Entity/Trigger.enabled = false
		
	$Polygon2D.color = Color(1,1,1,0.4) if type == TYPE.glass else Color('#4f4f3c')
	
	# workaround for losing texture mode
	$line.texture_mode = Line2D.LINE_TEXTURE_TILE
	#$lineBelow.texture_mode = Line2D.LINE_TEXTURE_TILE
	
	# grid color
	$Grid.modulate = grid_color
	
	#$line.width = line_width
	#$lineBelow.width = line_width
	
	update_iso()
	
	if not $PlatformArea/CollisionShape2D.shape:
		$PlatformArea/CollisionShape2D.shape = ConvexPolygonShape2D.new()
	$PlatformArea/CollisionShape2D.shape.set_points(points)
	
	
func _process(delta):
	update_iso()
	
func update_iso():
	if not Engine.editor_hint: # global is not available at editor time
		$lineBelow.position = global.isometric_offset.rotated(-global_rotation)
	
func animate(animation_name: String):
	if $AnimationPlayer:
		if $AnimationPlayer.assigned_animation != animation_name:
			$AnimationPlayer.play(animation_name)
			

func get_strategy(ship, distance, game_mode):
	return {"avoid": 0.1}
