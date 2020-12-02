tool

extends Node2D

enum TYPE { trigger, water, hostile, flow, castle, hill, basket, ghost, conquerable }
export(TYPE) var type = TYPE.water setget set_type

export var flag_offset : int = 0 setget set_flag_offset
export var isometric_effect = true
export var opaque_tint : Color = Color(0,0,0,0.8) setget set_opaque_tint

func set_opaque_tint(v):
	opaque_tint = v
	yield(self, 'ready')
	$IsoPolygon.opaque_tint = opaque_tint

func set_type(value):
	type = value
	refresh()
	
func set_flag_offset(value):
	flag_offset = value
	refresh()
	
func _ready():
	refresh()
	
func _on_GShape_changed():
	refresh()
	
func refresh():
	var gshape = get_gshape()
	
	if not gshape:
		return
		
	if not gshape.is_connected('changed', self, '_on_GShape_changed'):
		gshape.connect('changed', self, '_on_GShape_changed')
		
	$Polygon2D.polygon = gshape.to_PoolVector2Array()
	$Line2D.points = gshape.to_closed_PoolVector2Array()
	$Area2D/CollisionShape2D.set_shape(gshape.to_Shape2D())
	$CrownCollider/CollisionShape2D.set_shape(gshape.to_Shape2D())
	
	# isometric effect
	$IsoPolygon.visible = isometric_effect and type != TYPE.water
	$IsoPolygon.shape = gshape
	
	var shape2d = gshape.to_Shape2D()
	
	($Area2D/Entity/Water as Component).set_enabled(type == TYPE.water)
	($Area2D/Entity/Trigger as Component).set_enabled(type == TYPE.trigger or type == TYPE.hostile)
	($Area2D/Entity/Deadly as Component).set_enabled(type == TYPE.hostile)
	($Area2D/Entity/Flow as Component).set_enabled(type == TYPE.flow)
	($Area2D/Entity/CrownDropper as Component).set_enabled(type == TYPE.castle)
	$CrownCollider/CollisionShape2D.disabled = type != TYPE.castle
	$CrownCollider.visible = type == TYPE.castle
	$Particles2D.emitting = type == TYPE.flow
	($Area2D/Entity/Strategic as Component).set_enabled(type == TYPE.hill or type == TYPE.conquerable)
	($Area2D/Entity/Hill as Component).set_enabled(type == TYPE.hill)
	($Area2D/Entity/Basket as Component).set_enabled(type == TYPE.basket)
	
	$Polygon2D.visible = type != TYPE.ghost
	# $Line2D.visible = type != TYPE.water
	material = null
	if type == TYPE.water:
		#$Polygon2D.color = Color(0,0.2,0.8,0.5)
		$Polygon2D.color = Color(1,1,1,1)
		material = load("res://assets/shaders/water_shader.tres")
		$Polygon2D.texture_offset = gshape.get_extents()
		$Line2D.default_color = Color(0,0.2,0.6,1)
	elif type == TYPE.trigger:
		$Polygon2D.color = Color(1,1,1,0.3)
		$Line2D.default_color = Color(1,1,1,1)
	elif type == TYPE.hostile:
		$Polygon2D.color = Color(1,0,0,0.3)
		$Line2D.default_color = Color(1,0,0,1)
	elif type == TYPE.flow:
		$Polygon2D.color = Color(1,1,0,0.3)
		$Line2D.default_color = Color(1,1,0,1)
	elif type == TYPE.castle:
		$Polygon2D.color = Color(1,1,1,0.3)
		$Line2D.default_color = Color(1,1,1,1)
	elif type == TYPE.hill:
		$Polygon2D.color = Color(1,0.5,0,0.3)
		$Line2D.default_color = Color(1,0.5,0,1)
		$Area2D/Entity/Hill/Crown.modulate = Color(1,0.5,0,1)
	elif type == TYPE.basket:
		#assert ($Entity as Entity).has('Owned')
		
		var species = ($Area2D/Entity as Entity).get('Owned').get_owned_by()
		$Polygon2D.color = species.color.darkened(10)
		$Line2D.default_color = species.color
	elif type == TYPE.ghost:
		$Line2D.default_color = Color(0.2,0.7,1,0.2)
	
	# hill symbol on top
	$Area2D/Entity/Hill.position.y = -gshape.get_extents().y/2 - 60
	
	# configure particles
	if type == TYPE.flow:
		var material = $Particles2D.process_material
		
		if $Area2D/Entity/Flow.type == $Area2D/Entity/Flow.TYPE.center:
			material.radial_accel = $Area2D/Entity/Flow.charge * 6
		else:
			material.radial_accel = 0
			
		# TODO direction flows
		
		if gshape is GCircle:
			material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_SPHERE
			material.emission_sphere_radius = gshape.radius
		elif gshape is GRect:
			material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_BOX
			material.emission_box_extents = Vector3(gshape.width/2, gshape.height/2, 0)
		else:
			# other shapes are unupported
			$Particles2D.emitting = false
			
	# configure buoyancy
	if type == TYPE.water:
		$Area2D.space_override = Area2D.SPACE_OVERRIDE_REPLACE
		
		if gshape is GCircle:
			$Area2D.gravity_point = true
			$Area2D.gravity_vec = Vector2(0,0) # center
			$Area2D.gravity = -98 # repulsive
		elif gshape is GRect:
			$Area2D.gravity_point = false
			$Area2D.gravity_vec = Vector2(0,1)
			$Area2D.gravity = -49 # repulsive
		else:
			# other shapes are unupported
			$Area2D.space_override = Area2D.SPACE_OVERRIDE_DISABLED
	else:
		$Area2D.space_override = Area2D.SPACE_OVERRIDE_DISABLED
	
	# conquerable
	($Area2D/Entity/Conquerable as Component).set_enabled(type == TYPE.conquerable)
	$Flag.set_visible(false)
	# $Flag.set_visible(type == TYPE.conquerable)
	
	# move flag symbol
	$Flag.position.y = -flag_offset
	
	if type == TYPE.conquerable:
		# add_to_group('in_camera')
		pass
	else:
		if is_in_group('in_camera'):
			remove_from_group('in_camera')
		
func _process(delta):
	if not Engine.is_editor_hint() and ($Area2D/Entity/Conquerable as Component).enabled:
		if $Area2D/Entity/Conquerable.get_species() != null:
			$Polygon2D.color = Color(1,1,1,0.3)
			$Line2D.default_color = Color(1,1,1,0.6)
			modulate = $Area2D/Entity/Conquerable.get_species().species_template.color
		else:
			$Polygon2D.color = Color(0.3,0.3,0.3,0.1)
			$Line2D.default_color = Color(0.6,0.6,0.6,0.3)
			modulate = Color(1,1,1,1)
	
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func _get_configuration_warning():
	if not get_gshape():
		return 'Please provide a GShape as child node to define the geometry.\n'
	return ''
	
signal entered
func _on_Area2D_body_entered(body):
	emit_signal("entered", self, body)
	
signal exited
func _on_Area2D_body_exited(body):
	emit_signal("exited", self, body)
	
