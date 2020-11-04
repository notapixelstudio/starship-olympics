tool
extends Node2D

export var size : float = 8 setget set_size
export var goal_owner : NodePath
var species

func set_size(v):
	size = v
	yield(self, 'ready')
	$Sprite.scale = Vector2(size, size)

func _ready():
	species = get_node(goal_owner).species
	modulate = species.color
	$Sprite.texture = species.ship_w
	
	# decal is on the floor
	$Sprite.position = global.isometric_offset.rotated(-global_rotation)
	
