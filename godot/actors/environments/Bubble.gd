tool
extends RigidBody2D

class_name Bubble

signal killed

func get_class():
	return 'Bubble'

const max_group_size = 3
var about_to_pop = false

onready var radius = $CollisionShape2D.shape.radius

onready var ChemicalBondScene = preload('res://actors/environments/ChemicalBond.tscn')

export var owner_player : NodePath
var species : Resource

var group = {}

var points = 1

func _ready():
	group = {
		get_name(): self
	}
	# set color if bubble is owned by a player
	yield(get_tree(), "idle_frame")
	if owner_player:
		set_species(get_node(owner_player).species)

func set_species(v):
	species = v
	$NoRotate/Sprite.modulate = species.color
	$NoRotate/Label.modulate = species.color
	$Particles2D.modulate = species.color
	$Particles2D2.modulate = species.color_2
	$NoRotate/Label.text = species.species_name.left(1).to_upper()# + species.species_name.substr(1,1)

func _process(delta):
	$NoRotate.rotation = -rotation
	#$NoRotate/Label.text = str(points)
	
func get_color():
	return $NoRotate/Sprite.modulate
	
func attempt_binding(bubble_shooter):
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
				# update points
				b.points = len(b.group)
			
			maybe_pop(bubble_shooter) 

func maybe_pop(bubble_shooter):
	yield(get_tree().create_timer(0.6), 'timeout') # wait a bit to compute all group bindings
	
	# pop all group if max_group_size is reached
	if group and len(group) >= max_group_size:
		for b in group.values():
			if b:
				b.pop(bubble_shooter)
	
func pop(bubble_shooter):
	group.erase(get_name())
	about_to_pop = true
	$AnimationPlayer.play('pop')
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal('killed', self, bubble_shooter)
	yield($AnimationPlayer, "animation_finished")
	queue_free()
