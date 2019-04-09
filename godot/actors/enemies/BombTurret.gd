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
var target

func initialize(_arena):
	arena = _arena

func change_owner(ship: Ship):
	sprite.modulate = ship.species_template.color

func _process(delta):
	aim()
	update()
	if target:
		var res = (position - target).angle()
		res = abs(fposmod(res, PI*2))
		rotation = abs(fposmod(rotation, PI*2))
		if abs(rotation - res) > PI:
			res = res - PI *2
		rotation = lerp(rotation, res, 0.1)
		print(rotation, " vs ", res)

func dist(a: Vector2, b: Vector2):
	return (b-a).length()

func nearest_in(objects):
	var nearest = null
	var min_dist
	for object in objects:
		if not nearest or dist(object, position) < min_dist:
			nearest = object
			min_dist = dist(nearest, position)
	return nearest
	
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
	target = nearest_in(target_pos)

func _draw():
	for hit in target_pos:
		draw_circle((hit - position).rotated(-rotation), 5, laser_color)
		draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)

func shoot():
	"""
	Fire a bomb
	"""
	var charge_impulse = 2.5
	if not target:
		return
	var target_impulse = target - position
	var bomb = arena.spawn_bomb(
	  position + target_impulse.normalized(),
	  charge_impulse * target_impulse,
	  owner_ship
	)
func _on_Timer_timeout():
	shoot()

