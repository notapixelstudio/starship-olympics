tool

extends Node2D

enum TYPE { trigger, water, hostile, flow, castle, hill }
export(TYPE) var type = TYPE.water setget set_type

func set_type(value):
	type = value
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
	$Area2D/CollisionShape2D.shape = gshape.to_Shape2D()
	$CrownCollider/CollisionShape2D.shape = gshape.to_Shape2D()
	
	($Entity/Fluid as Component).set_enabled(type == TYPE.water)
	($Entity/Trigger as Component).set_enabled(type == TYPE.trigger or type == TYPE.hostile)
	($Entity/Deadly as Component).set_enabled(type == TYPE.hostile)
	($Entity/Flow as Component).set_enabled(type == TYPE.flow)
	($Entity/CrownDropper as Component).set_enabled(type == TYPE.castle)
	$CrownCollider/CollisionShape2D.disabled = type != TYPE.castle
	$CrownCollider.visible = type == TYPE.castle
	$Particles2D.emitting = type == TYPE.flow
	($Entity/Valuable as Component).set_enabled(type == TYPE.hill)
	($Entity/Throne as Component).set_enabled(type == TYPE.hill)
	
	if type == TYPE.water:
		$Polygon2D.color = Color(0,0.2,0.8,0.5)
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
		$Polygon2D.color = Color(0.5,0,0.5,0.3)
		$Line2D.default_color = Color(0.5,0,0.5,1)
	elif type == TYPE.hill:
		$Polygon2D.color = Color(1,0.5,0,0.3)
		$Line2D.default_color = Color(1,0.5,0,1)
		
	# keep the symbols up
	$CrownCollider/Sprite.rotation = -rotation
	
	# configure particles
	if type == TYPE.flow:
		var material = $Particles2D.process_material
		
		if $Entity/Flow.type == $Entity/Flow.TYPE.center:
			material.radial_accel = $Entity/Flow.charge * 6
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
	