tool
extends RigidBody2D

class_name Bubble

func get_class():
	return 'Bubble'

onready var radius = $CollisionShape2D.shape.radius

onready var ChemicalBondScene = preload('res://actors/environments/ChemicalBond.tscn')

export var species : Resource setget set_species

func set_species(v):
	species = v
	$Sprite.modulate = species.color
	$Sprite/Label.text = species.species_name.left(1).to_upper()# + species.species_name.substr(1,1)

func _process(delta):
	$Sprite.rotation = -rotation
	
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
