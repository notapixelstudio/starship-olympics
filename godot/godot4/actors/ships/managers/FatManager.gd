extends Node

var host : Ship
var fat := 1.0
var base_mass : float
var base_rotation_torque : float
var base_scale : Vector2
var base_radius : float
var base_hit_radius : float
var base_hurt_radius : float
var base_charge_bar_offset : float

func _ready():
	host = get_parent()
	assert(host is Ship)
	host.hit.connect(_on_ship_hit_sth)
	
	base_mass = host.mass
	base_rotation_torque = host.rotation_torque
	base_scale = host.get_node("%Graphics").scale
	base_radius = host.get_node("%ShipShape2D").shape.radius
	base_hit_radius = host.get_node("%HitShape2D").shape.radius
	base_hurt_radius = host.get_node("%HurtShape2D").shape.radius
	base_charge_bar_offset = host.get_node("%ChargeBar").position.x
	
func _on_ship_hit_sth(sth: PhysicsBody2D) -> void:
	if sth.name == 'Food':
		_grow()
		
func _grow() -> void:
	fat *= 1.3
	host.mass = sqrt(fat) * base_mass
	host.rotation_torque = fat * fat * base_rotation_torque
	host.get_node("%Graphics").scale = fat * base_scale
	host.get_node("%ShipShape2D").shape.radius = fat * base_radius
	host.get_node("%HitShape2D").shape.radius = fat * base_hit_radius
	host.get_node("%HurtShape2D").shape.radius = fat * base_hurt_radius
	host.get_node("%ChargeBar").position.x = fat * base_charge_bar_offset
