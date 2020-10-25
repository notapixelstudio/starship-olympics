tool
extends RigidBody2D

onready var radius = $CollisionShape2D.shape.radius

export var species : Resource setget set_species

func set_species(v):
	species = v
	$Sprite.modulate = species.color
	$Sprite/Label.text = species.species_name.left(1).to_upper()# + species.species_name.substr(1,1)

func _process(delta):
	$Sprite.rotation = -rotation
	
func get_color():
	return $Sprite.modulate
	
