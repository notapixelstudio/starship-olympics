extends StaticBody2D

class_name BombTurret

var arena
export (Resource) var owned_by_species 
export (String) var owned_by_player
export (PackedScene) var bomb_scene
var owner_ship
onready var sprite = $Turret

const laser_color = Color(1.0, .329, .298)
var target_pos = []

const BOMB_OFFSET = 60

func initialize(_arena):
	arena = _arena

func change_owner(ship: Ship):
	sprite.modulate = ship.species_template.color

func _process(delta):
	aim()
	update()
	if target_pos:
		var res = (position - target_pos[0]).angle()
		res = abs(fposmod(res, PI*2))
		rotation = abs(fposmod(rotation, PI*2))
		if abs(rotation - res) > PI:
			res = res - PI *2
		rotation = lerp(rotation, res, 0.1)
		print(rotation, " vs ", res)

		
	
func aim():
	target_pos = []
	var ships = get_tree().get_nodes_in_group("players")
	var space_state = get_world_2d().direct_space_state
	for ship in ships:
		if ship == owner_ship:
			continue
		var pos = ship.position
		var result = space_state.intersect_ray(position, pos, [self], collision_mask)
		if result:
			target_pos.append(result.position)

func _draw():
	for hit in target_pos:
		draw_circle((hit - position).rotated(-rotation), 5, laser_color)
		draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)

func shoot():
	"""
	Fire a bomb
	"""
	var charge_impulse = 2.5
	var target = target_pos[0]
	var target_impulse = target - position
	var bomb = arena.spawn_bomb(
	  position + target_impulse.normalized(),
	  charge_impulse * target_impulse,
	  owner_ship
	)
func _on_Timer_timeout():
	shoot()

