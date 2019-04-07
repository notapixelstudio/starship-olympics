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

func initialize(_arena):
	arena = _arena

func change_owner(ship: Ship):
	sprite.modulate = ship.species_template.color

func _process(delta):
	aim()
	update()
	
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
	var bomb = arena.spawn_bomb(position, null, owner_ship)
	ECM.E(bomb).get("StandAlone").enable()
	bomb.connect("detonate", self, "ready_to_respawn",[], CONNECT_ONESHOT)
	
func ready_to_respawn():
	yield(get_tree().create_timer(5.0), "timeout")
	shoot()