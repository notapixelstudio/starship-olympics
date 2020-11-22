tool
extends RigidBody2D

class_name Bubble

func get_class():
	return 'Bubble'

const max_group_size = 4

onready var radius = $CollisionShape2D.shape.radius

onready var ChemicalBondScene = preload('res://actors/environments/ChemicalBond.tscn')

export var species : Resource setget set_species

var group = {
	get_instance_id(): self
}

func set_species(v):
	species = v
	$Sprite.modulate = species.color
	$Sprite/Label.text = species.species_name.left(1).to_upper()# + species.species_name.substr(1,1)

func _process(delta):
	$Sprite.rotation = -rotation
	#$Sprite/Label.text = str(len(group))
	
func get_color():
	return $Sprite.modulate
	
func attempt_binding():
	yield(get_tree().create_timer(0.1), 'timeout')
	for bubble in $BindingArea.get_overlapping_bodies():
		if bubble == self or bubble.get_class() != 'Bubble':
			continue
			
		var bond = ChemicalBondScene.instance()
		bond.node_a = get_path()
		bond.node_b = bubble.get_path()
		add_child(bond)
		
		if species == bubble.species:
			# update groups
			# merge
			for k in bubble.group.keys():
				group[k] = bubble.group[k]
			# share reference
			for b in group.values():
				b.group = group
			
			maybe_pop() 

func maybe_pop():
	yield(get_tree().create_timer(0.6), 'timeout') # wait a bit to compute all group bindings
	
	# pop all group if max_group_size is reached
	if len(group) >= max_group_size:
		for b in group.values():
			b.pop()
	
func pop():
	group.erase(get_instance_id())
	queue_free()
	
