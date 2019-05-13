tool
extends RigidBody2D

class_name Asteroid

enum TYPE { solid, conquerable }
export(TYPE) var type = TYPE.solid setget set_type

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
	$CollisionShape2D.shape = gshape.to_Shape2D()
	
	($Entity/Conquerable as Component).set_enabled(type == TYPE.conquerable)
	$Flag.set_visible(type == TYPE.conquerable)
	
	if type == TYPE.solid or type == TYPE.conquerable:
		$Polygon2D.color = Color(0.6,0.6,0.6,0.5)
		$Line2D.default_color = Color(1,1,1,1)
		
	if type == TYPE.conquerable:
		add_to_group('in_camera')
	else:
		remove_from_group('in_camera')
		
func _process(delta):
	if not Engine.is_editor_hint() and ($Entity/Conquerable as Component).enabled and ($Entity/Conquerable as Conquerable).get_species() != null:
		modulate = ($Entity/Conquerable as Conquerable).get_species().species_template.color
		
func get_gshape():
	for child in get_children():
		if child is GShape:
			return child
	return null
	
func _get_configuration_warning():
	if not get_gshape():
		return 'Please provide a GShape as child node to define the geometry.\n'
	return ''
	