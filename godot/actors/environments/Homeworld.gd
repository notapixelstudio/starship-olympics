tool
extends "res://actors/environments/Planet.gd"
class_name Homeworld

export (String, 'animals/a00', 'animals/a01', 'animals/a02', 'animals/a03', 'animals/a04') var kind := 'animals/a00' setget set_kind, get_kind

const COLORS := {
	'animals/a00': Color('#ec7505'),
	'animals/a01': Color('#e9c000'),
	'animals/a02': Color('#a01754'),
	'animals/a03': Color('#5171a5'),
	'animals/a04': Color('#2bb077')
}

func set_ground_radius(v):
	.set_ground_radius(v)
	if not is_inside_tree():
		yield(self, 'ready')
	$Alien.scale = Vector2(1.2,1.2)*v/200.0

func set_kind(v):
	kind = v
	if not is_inside_tree():
		yield(self, 'ready')
	$Alien.texture = load('res://assets/sprites/' + kind + '.png')
	$Ground.modulate = COLORS[kind]

func get_kind():
	return kind
