tool
extends "res://actors/environments/Planet.gd"
class_name Homeworld

export (String, 'animals/a00', 'animals/a01', 'animals/a02', 'animals/a03', 'animals/a04') var kind := 'animals/a00' setget set_kind, get_kind

const COLORS := {
	'animals/a00': Color.orangered,
	'animals/a01': Color.yellow,
	'animals/a02': Color.mediumvioletred,
	'animals/a03': Color.cornflower,
	'animals/a04': Color.mediumseagreen
}

func set_ground_radius(v):
	.set_ground_radius(v)
	if not is_inside_tree():
		yield(self, 'ready')
	$Alien.scale = Vector2(1,1)*v/200.0

func set_kind(v):
	kind = v
	if not is_inside_tree():
		yield(self, 'ready')
	$Alien.texture = load('res://assets/sprites/' + kind + '.png')
	$Ground.modulate = COLORS[kind]

func get_kind():
	return kind
