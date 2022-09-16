@tool

extends StaticBody2D
class_name Wall

@export (bool) var hollow :
	get:
		return hollow # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_hollow

@export (int) var offset = 800 :
	get:
		return offset # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_offset
@export (int) var elongation :
	get:
		return elongation # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_elongation

enum TYPE { solid, hostile, ghost, decoration, glass }
@export var type: TYPE = TYPE.solid :
	get:
		return type # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_type

@export var hide_line : bool = false :
	get:
		return hide_line # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_hide_line
@export var hide_line_below : bool = false :
	get:
		return hide_line_below # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_hide_line_below
@export var hide_grid : bool = false :
	get:
		return hide_grid # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_hide_grid

@export var line_width = 48 :
	get:
		return line_width # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_line_width

@export var solid_line_color = Color8(208, 245, 295, 255) :
	get:
		return solid_line_color # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_solid_line_color
@export var line_texture : Texture2D :
	get:
		return line_texture # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_line_texture

@export var grid_color : Color = Color(1,1,1,0.33) :
	get:
		return grid_color # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_grid_color
@export var grid_rotation : float = 0 :
	get:
		return grid_rotation # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_grid_rotation

@export var platform = false
@export var under = 'both' setget set_under # (String, 'both', 'above', 'below')

const texture_glass = preload('res://assets/sprites/stripes.png')
const spikes_texture = preload("res://assets/patterns/wall/spikesii.png")

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
	set_collision_layer_value(4, false)
	add_to_group('nostyle')
	
	if under == 'below':
		z_as_relative = false
		z_index = -50
		$line.z_index = -50
		$lineBelow.z_index = -60
		$InnerPolygon2D.visible = false
		set_collision_mask_value(0, false)
		set_collision_mask_value(18, true)
		modulate = Color(0.5,0.5,1)
		$Polygon2D.color = Color(0.7,0.7,0.7)
	elif under == 'above':
		z_as_relative = true
		z_index = 0
		$line.z_index = 0
		$lineBelow.z_index = -10
		$InnerPolygon2D.visible = false
		set_collision_mask_value(0, true)
		set_collision_mask_value(18, false)
		modulate = Color(1,0.5,0.5)
		$Polygon2D.color = Color(0.7,0.7,0.7)
	elif under == 'both':
		z_as_relative = true
		z_index = 0
		$line.z_index = 0
		$lineBelow.z_index = -10
		$InnerPolygon2D.visible = true
		set_collision_layer_value(4, true)
		set_collision_mask_value(0, true)
		set_collision_mask_value(18, true)
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
	$PlatformArea/CollisionShape2D.set_deferred('disabled', not platform and name != 'OutsideWall')

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
		if child is CollisionShape2D or child is CollisionPolygon2D:
			remove_child(child)
			child.queue_free()
	
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func _get_configuration_warnings():
	if not get_gshape():
		return 'Please provide a GShape as child node to define the geometry.\n'
	return ''
	
func refresh():
	remove_old_shapes()
	
	var gshape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed',Callable(self,'refresh')):
		gshape.connect('changed',Callable(self,'refresh'))
		
	var points = gshape.to_PoolVector2Array()
	
	if not type == TYPE.ghost and not type == TYPE.decoration:
		if hollow:
			for i in range(len(points)):
				var cshape = CollisionShape2D.new()
				var shape = ConvexPolygonShape2D.new()
				var a = points[i]
				var b = points[(i+1) % len(points)]
				# elongation is used to avoid jumping outside the battlefield walls
				var elo = (b-a).normalized()*elongation
				var elo_polygon := PackedVector2Array([a-elo,a+a.normalized()*offset-elo,b+b.normalized()*offset+elo,b+elo])
				var clipped_elo_polygons : Array = Geometry2D.clip_polygons(elo_polygon, points) # this is to avoid elongation spikes inside the arena
				if len(clipped_elo_polygons) > 0:
					shape.set_points(clipped_elo_polygons[0])
				else:
					shape.set_points(elo_polygon)
				cshape.set_shape(shape)
				add_child(cshape)
				
		else:
			var cpolygon = CollisionPolygon2D.new()
			cpolygon.visible = false
			cpolygon.polygon = points
			add_child(cpolygon)
			
	$InnerPolygon2D.visible = not hollow and not(type == TYPE.ghost) and not(type == TYPE.glass) and under == 'both'
	
	$Polygon2D.set_polygon(points)
	var shrunk = Geometry2D.offset_polygon(points, -40)
	if len(shrunk) > 0:
		$InnerPolygon2D.set_polygon(shrunk[0])
	else:
		$InnerPolygon2D.set_polygon(points)
	$Grid.set_polygon(points)
	
	$Polygon2D.visible = not hollow and not type == TYPE.ghost# and not type == TYPE.decoration
	$Grid.visible = hollow and not type == TYPE.ghost and not type == TYPE.decoration and not hide_grid
	$line.visible = not hide_line
	$lineBelow.visible = not hide_line_below
	
	$Grid.set_texture_rotation(rotation + deg_to_rad(grid_rotation))
	
	# glass pass-through
	set_collision_layer_value(4, type != TYPE.glass and under == 'both')
	$Polygon2D.self_modulate = Color(1,1,1,0.8) if type == TYPE.glass or under == 'above' else Color(1,1,1,1)
	$Polygon2D.texture = texture_glass if type == TYPE.glass else null
	$Polygon2D.set_texture_rotation(rotation)
	$Entity/CrownDropper.enabled = type == TYPE.glass
	
	# close the line with a seamless join
	var ps = PackedVector2Array(points)
	ps.remove_at(0)
	var p = points[0]+(points[1]-points[0])*0.5
	$line.points = PackedVector2Array([p]) + ps + PackedVector2Array([points[0], p])
	$lineBelow.points = PackedVector2Array([p]) + ps + PackedVector2Array([points[0], p])
	
	$line.texture = line_texture
	$lineBelow.texture = line_texture
	
	# wall types
	$lineBelow.self_modulate = Color(0.6,0.6,0.6,1) # default
	var color
	if type == TYPE.hostile:
		color = Color(1.2, 0, 0.35)
		$Polygon2D.modulate = color
		$InnerPolygon2D.modulate = color
		$line.modulate = color
		$lineBelow.modulate = color
		$Entity/Deadly.enabled = true
		$Entity/Trigger.enabled = true
		$line.texture = spikes_texture
		$lineBelow.visible = false
	elif type == TYPE.solid:
		$Polygon2D.modulate = solid_line_color
		$InnerPolygon2D.modulate = solid_line_color
		$line.modulate = solid_line_color
		$lineBelow.modulate = solid_line_color
		$Entity/Deadly.enabled = false
		$Entity/Trigger.enabled = false
	elif type == TYPE.ghost:
		$line.visible = false
		$lineBelow.self_modulate = Color(1,1,1,1)
		$lineBelow.modulate = Color(0.2,0.4,1,0.2)
	elif type == TYPE.decoration:
		$Polygon2D.modulate = solid_line_color
		$InnerPolygon2D.modulate = solid_line_color
		$line.modulate = solid_line_color
		$lineBelow.modulate = solid_line_color
	elif type == TYPE.glass:
		color = Color(0.4,0.7,1.2,1)
		$Polygon2D.modulate = color
		$InnerPolygon2D.modulate = color
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
