extends Node

var arena: Arena
var checks := 0

func check(ok: bool, message: String) -> bool:
	if not ok:
		push_error("FAMILIAR FAIL: " + message)
		get_tree().quit(1)
		return false
	checks += 1
	print("FAMILIAR PASS: " + message)
	return true

func settle(frames := 4) -> void:
	for i in frames:
		await get_tree().physics_frame
		await get_tree().process_frame

func drones(ship: Ship) -> Array:
	return ship.get_children().filter(func(child): return child is Familiar)

func of_scene(ship: Ship, scene_name: String) -> Array:
	return drones(ship).filter(func(node): return node.definition.resource_path.ends_with(scene_name + ".tscn"))

func diamonds() -> Array:
	return arena.get_node("%Battlefield").get_children().filter(func(node):
		return node is Collectable and node.scene_file_path.ends_with("/Diamond.tscn"))

func shot(where: Vector2, team: String, velocity := Vector2.ZERO) -> Pew:
	var pew := load("res://godot4/elements/projectiles/Pew.tscn").instantiate() as Pew
	pew.set_team(team)
	pew.set_color(Color.WHITE)
	pew.position = where
	pew.linear_velocity = velocity
	arena.get_node("%Battlefield").add_child(pew)
	return pew

func _ready() -> void:
	arena = load("res://godot4/minigames/deathmatch/pvp/2p.tscn").instantiate()
	arena.session = Session.new()
	# Exercise carried items before ships enter, as well as a live pickup for P1.
	arena.session.grant_item(load("res://godot4/data/items/orbiting_familiar/orbiting_familiar_run.tres"), arena.players[1].get_id())
	arena.session.grant_item(load("res://godot4/data/items/follower_familiar/follower_familiar_run.tres"), arena.players[1].get_id())
	add_child(arena)
	for player in arena.players.slice(0, 2):
		Events.player_ready.emit(player)
	await settle()
	var manager = arena.get_node("%ItemManager")
	var ship: Ship = manager._ships(arena.players[0].get_id())[0]
	var other: Ship = manager._ships(arena.players[1].get_id())[0]
	if not check(of_scene(other, "OrbitingFamiliar").size() == 1 and of_scene(other, "FollowerFamiliar").size() == 1 and drones(ship).is_empty(), "both carried familiar types attach only to their owner at match start"): return
	ship.freeze = true
	ship.position = Vector2.ZERO
	var pickup := load("res://godot4/elements/collectables/items/orbiting_familiar/orbiting_familiar_run.tscn").instantiate() as Collectable
	arena.get_node("%Battlefield").add_child(pickup)
	pickup.collect(ship)
	await settle()
	if not check(drones(ship).size() == 1, "real pickup attaches familiar through ItemManager"): return
	var drone: Familiar = of_scene(ship, "OrbitingFamiliar")[0]
	var orbit := drone.get_node("OrbitMovement") as OrbitMovement
	var interception := drone.get_node("ProjectileInterception") as ProjectileInterception
	var before := drone.global_position
	await settle(12)
	if not check(drone.global_position.distance_to(before) > 5, "familiar orbits over physics frames"): return
	if not check(absf(drone.global_position.distance_to(ship.global_position) - orbit.orbit_radius) < 1, "orbit stays at configured radius"): return
	ship.position += Vector2(250, 150)
	ship.rotation += PI / 2
	await settle()
	if not check(absf(drone.global_position.distance_to(ship.global_position) - orbit.orbit_radius) < 1, "orbit follows ship translation and steering"): return
	orbit.orbit_speed = 0
	var friend := shot(drone.global_position, ship.get_team())
	await settle()
	if not check(is_instance_valid(friend) and interception.recharge_left == 0, "friendly projectile passes through"): return
	friend.queue_free()
	var enemy := shot(drone.global_position, "enemy")
	await settle()
	if not check(not is_instance_valid(enemy) and interception.recharge_left > 0, "physics overlap intercepts enemy projectile"): return
	var during := shot(drone.global_position, "enemy")
	await settle()
	if not check(is_instance_valid(during), "recharging familiar lets shots through"): return
	interception.recharge_left = 0.03
	await settle(8)
	if not check(not is_instance_valid(during), "recharged familiar intercepts an already overlapping shot"): return
	interception.recharge_left = 0
	var fast := shot(drone.global_position + Vector2(0, -200), "enemy", Vector2(0, 4000))
	await settle(8)
	if not check(not is_instance_valid(fast) and interception.recharge_left > 0, "intercepts a moving 4000px/s projectile"): return
	# Hold the orbit steady while a ship moves across a projectile.
	interception.recharge_left = 0
	ship.freeze = false
	ship.linear_velocity = Vector2(0, 6000)
	var crossing := shot(drone.global_position + Vector2(0, 200), "enemy")
	await settle(5)
	ship.freeze = true
	ship.linear_velocity = Vector2.ZERO
	if not check(not is_instance_valid(crossing) and interception.recharge_left > 0, "familiar intercepts while ship moves at dash speed"): return
	var glass_pickup := load("res://godot4/elements/collectables/items/orbiting_familiar/orbiting_familiar_run_glass.tscn").instantiate() as Collectable
	arena.get_node("%Battlefield").add_child(glass_pickup)
	glass_pickup.collect(ship)
	await settle()
	if not check(of_scene(ship, "OrbitingFamiliar").size() == 2 and of_scene(other, "OrbitingFamiliar").size() == 1, "glass orbiter pickup stacks only for its owner"): return
	# Follower pickup coexists with the orbiters and uses world-space trailing movement.
	ship.position = Vector2.ZERO
	ship.rotation = 0
	var follower_pickup := load("res://godot4/elements/collectables/items/follower_familiar/follower_familiar_run.tscn").instantiate() as Collectable
	arena.get_node("%Battlefield").add_child(follower_pickup)
	follower_pickup.collect(ship)
	await settle()
	var followers := of_scene(ship, "FollowerFamiliar")
	if not check(followers.size() == 1 and drones(ship).size() == 3, "follower and orbiters coexist as separate items"): return
	var follower: Familiar = followers[0]
	var start := follower.global_position
	ship.position += Vector2(400, 0)
	await settle()
	if not check(follower.global_position.x > start.x and follower.global_position.x < start.x + 400, "follower trails instead of snapping to ship"): return
	await settle(60)
	var stationary := follower.global_position
	ship.rotation = PI / 2
	await settle(12)
	if not check(follower.global_position.distance_to(stationary) < 2, "follower stays put when stopped instead of orbiting"): return
	ship.tap.emit(0.2)
	await settle()
	var friendly_shots := arena.get_node("%Battlefield").get_children().filter(func(node): return node is Pew and node.get_team() == ship.get_team())
	if not check(friendly_shots.size() == 1, "follower fires a friendly Pew when player taps"): return
	friendly_shots[0].queue_free()
	var unblocked := shot(follower.global_position + Vector2(0, 40), "enemy")
	await settle()
	if not check(is_instance_valid(unblocked), "shooting follower does not block projectiles"): return
	unblocked.queue_free()
	glass_pickup = load("res://godot4/elements/collectables/items/follower_familiar/follower_familiar_run_glass.tscn").instantiate() as Collectable
	arena.get_node("%Battlefield").add_child(glass_pickup)
	glass_pickup.collect(ship)
	await settle()
	followers = of_scene(ship, "FollowerFamiliar")
	if not check(followers.size() == 2 and followers[1].get_node("FollowMovement").follow_target == followers[0] and of_scene(other, "FollowerFamiliar").size() == 1, "glass follower pickup chains only for its owner"): return
	var diamond_pickup := load("res://godot4/elements/collectables/items/diamond_familiar/diamond_familiar_run.tscn").instantiate() as Collectable
	arena.get_node("%Battlefield").add_child(diamond_pickup)
	diamond_pickup.collect(ship)
	await settle()
	var diamond_familiar: Familiar = of_scene(ship, "DiamondGeneratorFamiliar")[0]
	var generator := diamond_familiar.get_node("PickupGenerator") as PickupGenerator
	await settle()
	if not check(generator._timer.wait_time == 10.0 and not generator._pickup_active and diamonds().is_empty(), "generator waits 10 seconds before its first Diamond"): return
	generator._timer.wait_time = 0.1
	generator._timer.start()
	await settle(12)
	if not check(generator._pickup_active and diamonds().size() == 1, "generator drops one regular Diamond on its timer"): return
	await settle(12)
	if not check(diamonds().size() == 1, "generator keeps only one Diamond active at a time"): return
	diamonds()[0].collect(ship)
	await settle(12)
	if not check(generator._pickup_active and diamonds().size() == 1, "generator drops another Diamond on the next timer tick"): return
	var throwable_pickup := load("res://godot4/elements/collectables/items/throwable_familiar/throwable_familiar_run.tscn").instantiate() as Collectable
	arena.get_node("%Battlefield").add_child(throwable_pickup)
	throwable_pickup.collect(ship)
	await settle()
	var throwable_familiar: Familiar = of_scene(ship, "ThrowableFamiliar")[0]
	var thrower := throwable_familiar.get_node("ThrowableMovement") as ThrowableMovement
	var follow := throwable_familiar.get_node("FollowMovement") as FollowMovement
	if not check(absf(throwable_familiar.global_position.distance_to(ship.global_position) - follow.follow_distance) < 1, "thrower trails at normal follower distance while idle"): return
	var throw_start := throwable_familiar.global_position
	var throw_direction := Vector2.RIGHT.rotated(ship.global_rotation)
	var throw_wall := StaticBody2D.new()
	throw_wall.collision_layer = 16
	var wall_shape := CollisionShape2D.new()
	var wall_rectangle := RectangleShape2D.new()
	wall_rectangle.size = Vector2(240, 30)
	wall_shape.shape = wall_rectangle
	throw_wall.add_child(wall_shape)
	throw_wall.global_position = ship.global_position + throw_direction * 350
	arena.get_node("%Battlefield").add_child(throw_wall)
	await settle()
	ship.tap.emit(0.2)
	await settle(4)
	if not check(thrower.state == ThrowableMovement.State.THROWN and throwable_familiar.global_position.distance_to(throw_start) > 40, "tap launches the throwable ahead of the ship"): return
	await settle(20)
	if not check(thrower.state == ThrowableMovement.State.RETURNING, "thrower advances until the wall stops it"): return
	await settle(35)
	if not check(thrower.state == ThrowableMovement.State.FOLLOWING and absf(throwable_familiar.global_position.distance_to(ship.global_position) - follow.follow_distance) < 2, "thrower returns to follower position after hitting the wall"): return
	throw_wall.queue_free()
	var throw_target := load("res://godot4/actors/ships/Ship.tscn").instantiate() as Ship
	throw_target.set_player(Player.new())
	throw_target.get_player().team = "throwable-target"
	throw_target.respawns = false
	throw_target.global_position = ship.global_position + Vector2.RIGHT.rotated(ship.global_rotation) * 280
	arena.get_node("%Battlefield").add_child(throw_target)
	await settle()
	throw_target.freeze = true
	ship.tap.emit(0.2)
	await settle(12)
	if not check(thrower.state == ThrowableMovement.State.RETURNING and not is_instance_valid(throw_target), "thrower damages the first enemy it hits and returns"): return
	var bouncer_pickup := load("res://godot4/elements/collectables/items/bouncing_familiar/bouncing_familiar_run.tscn").instantiate() as Collectable
	arena.get_node("%Battlefield").add_child(bouncer_pickup)
	bouncer_pickup.collect(ship)
	await settle()
	var bouncer: Familiar = of_scene(ship, "BouncingFamiliar")[0]
	var bounce_movement := bouncer.get_node("BounceMovement") as BounceMovement
	if not check(absf(bounce_movement.velocity.x) >= bounce_movement.speed * 0.5 and absf(bounce_movement.velocity.y) >= bounce_movement.speed * 0.5, "bouncer starts on a diagonal heading"): return
	var bounce_start := bouncer.global_position
	await settle(10)
	if not check(bouncer.top_level and bouncer.global_position.distance_to(bounce_start) > 40, "bouncer moves independently through the arena"): return
	var damage_probe := load("res://godot4/actors/ships/Ship.tscn").instantiate() as Ship
	damage_probe.set_player(Player.new())
	damage_probe.get_player().team = "bouncer-target"
	damage_probe.respawns = false
	arena.get_node("%Battlefield").add_child(damage_probe)
	await settle()
	damage_probe.freeze = true
	bouncer.global_position = damage_probe.global_position
	await settle(4)
	if not check(not is_instance_valid(damage_probe), "bouncer contact damages an enemy ship"): return
	var player := ship.get_player()
	ship.disable()
	await settle()
	if not check(diamonds().is_empty(), "generator removes its uncollected Diamond when its ship goes down"): return
	var disabled = arena.get_node("%Battlefield").get_children().filter(func(node): return node is DisabledShip)[0]
	disabled._restore_ship()
	await settle()
	ship = manager._ships(player.get_id())[0]
	bouncer = of_scene(ship, "BouncingFamiliar")[0]
	var restored_generator := of_scene(ship, "DiamondGeneratorFamiliar")[0].get_node("PickupGenerator") as PickupGenerator
	restored_generator._timer.wait_time = 0.1
	restored_generator._timer.start()
	await settle(12)
	if not check(diamonds().size() == 1, "restored generator drops its next Diamond on schedule"): return
	if not check(drones(ship).size() == 5 and of_scene(ship, "OrbitingFamiliar").size() == 1 and of_scene(ship, "FollowerFamiliar").size() == 1 and of_scene(ship, "DiamondGeneratorFamiliar").size() == 1 and of_scene(ship, "ThrowableFamiliar").size() == 1 and of_scene(ship, "BouncingFamiliar").size() == 1, "respawn restores every durable familiar and removes both glass copies"): return
	if not check(of_scene(other, "OrbitingFamiliar").size() == 1 and of_scene(other, "FollowerFamiliar").size() == 1, "one owner's disable leaves the other owner's familiar types intact"): return
	ship.freeze = true
	ship.position = Vector2.ZERO
	drone = of_scene(ship, "OrbitingFamiliar")[0]
	orbit = drone.get_node("OrbitMovement") as OrbitMovement
	orbit.orbit_speed = 0
	await settle()
	for node in drones(other):
		node.free()
	other.freeze = true
	other.get_player().team = ship.get_team()
	other.position = drone.global_position
	await settle()
	if not check(is_instance_valid(other) and not other.is_queued_for_deletion(), "orbiter contact does not damage allies"): return
	manager._load_ball(other)
	other.get_player().team = "enemy"
	await settle()
	if not check(is_instance_valid(other) and not other.has_cargo(), "contact damage knocks out cargo before disabling its carrier"): return
	await settle(40)
	if not check(not is_instance_valid(other), "orbiter damages an enemy ship on contact"): return
	print("FAMILIAR LIVE: %d checks passed" % checks)
	arena.queue_free()
	await settle()
	get_tree().quit()
