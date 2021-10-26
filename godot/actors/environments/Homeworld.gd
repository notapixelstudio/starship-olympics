tool
extends "res://actors/environments/Planet.gd"

export var kind := 0 setget set_kind

const COLORS := [
	Color.orangered,
	Color.yellow,
	Color.mediumvioletred,
	Color.cornflower,
	Color.mediumseagreen
]

func set_ground_radius(v):
	.set_ground_radius(v)
	if not is_inside_tree():
		yield(self, 'ready')
	$Alien.scale = Vector2(1,1)*v/200.0

func set_kind(v):
	kind = v
	if not is_inside_tree():
		yield(self, 'ready')
	$Alien.texture = load('res://assets/sprites/animals/a0' + str(kind) + '.png')
	$Soil.modulate = COLORS[kind]
