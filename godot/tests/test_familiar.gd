extends Node
## Run: Godot --headless --path godot res://tests/test_familiar.tscn

var _cleanup: Array[Node] = []

func autofree(node: Node) -> Node:
	_cleanup.append(node)
	return node

func _ready() -> void:
	for check in [test_blocks_enemy_shot_then_recharges_without_blocking_friends,
		test_orbit_ignores_ship_heading, test_behavior_composition, test_item_copies_reconcile_on_pickup_respawn_and_removal,
		test_item_type_scene_references, test_generic_start_reconciles, test_pickup_variants_load, test_shapeoid_uses_physics_behavior,
		test_pursuer_prefers_shapeoids_then_enemy_ships,
		test_pursuer_collides_with_wall, test_pursuer_texture_and_shapeoid_launcher,
		test_turret_composes_generic_aim_behavior, test_turret_firing_uses_shared_behavior,
		test_new_familiar_behaviors]:
		if not await check.call():
			get_tree().quit(1)
			return
	var item_type := load("res://godot4/data/items/orbiting_familiar.tres") as ItemType
	assert(item_type.id == &"orbiting_familiar")
	for node in _cleanup:
		node.free()
	print("Familiar checks passed")
	get_tree().quit()


class Shot extends Pew:
	var destroyed := false
	func destroy() -> void:
		destroyed = true

class PursuerTestShip extends RigidBody2D:
	var team := ""
	func get_team() -> String:
		return team

class CargoShipTarget extends Node2D:
	func has_cargo() -> bool:
		return true

class FamiliarManager extends "res://godot4/arena/managers/ItemManager.gd":
	var held: Array = []
	var test_ship: Ship
	func _in_play(_holder: String) -> Array:
		return held.duplicate()
	func _type(id: StringName, _holder: String) -> ItemType:
		return load(ItemType.ITEMS_DIR + id + ".tres")
	func _ships(_holder: String) -> Array:
		return [test_ship] if test_ship != null else []
	func _show_badges(_ship: Ship) -> void:
		pass

func test_item_type_scene_references() -> bool:
	var actor_scenes := {
		&"orbiting_familiar": "OrbitingFamiliar",
		&"follower_familiar": "FollowerFamiliar",
		&"diamond_familiar": "DiamondGeneratorFamiliar",
		&"throwable_familiar": "ThrowableFamiliar",
		&"bouncing_familiar": "BouncingFamiliar",
		&"pursuer_familiar": "PursuerFamiliar",
	}
	for id in actor_scenes:
		var item_type := load(ItemType.ITEMS_DIR + id + ".tres") as ItemType
		assert(item_type.actor_scene != null)
		assert(item_type.actor_scene.resource_path == "res://godot4/actors/ships/%s.tscn" % actor_scenes[id])
	return true

func test_pursuer_prefers_shapeoids_then_enemy_ships() -> bool:
	var owner := autofree(PursuerTestShip.new()) as PursuerTestShip
	owner.team = "A"
	add_child(owner)
	owner.add_to_group("Ship")
	var opponent := autofree(PursuerTestShip.new()) as PursuerTestShip
	opponent.team = "B"
	opponent.position = Vector2(300, 0)
	add_child(opponent)
	opponent.add_to_group("Ship")
	var actor := autofree(load("res://godot4/actors/ships/PursuerFamiliar.tscn").instantiate()) as Node2D
	var movement := actor.get_node("PursueMovement")
	movement.configure(actor, owner)
	add_child(actor)
	assert(movement._find_target() == opponent)
	var shapeoid := autofree(Node2D.new()) as Node2D
	shapeoid.add_to_group("Shapeoid")
	shapeoid.position = Vector2(900, 0)
	add_child(shapeoid)
	assert(movement._find_target() == shapeoid)
	shapeoid.remove_from_group("Shapeoid")
	assert(movement._find_target() == opponent)
	var pickup := autofree(load("res://godot4/elements/collectables/items/pursuer_familiar/pursuer_familiar_run.tscn").instantiate()) as Collectable
	assert(pickup.item.id == &"pursuer_familiar")
	return true

func test_pursuer_collides_with_wall() -> bool:
	var owner := autofree(PursuerTestShip.new()) as PursuerTestShip
	owner.team = "A"
	owner.position = Vector2(-500, 0)
	owner.add_to_group("Ship")
	add_child(owner)
	var wall := autofree(StaticBody2D.new()) as StaticBody2D
	wall.collision_layer = 16
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(100, 500)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	add_child(wall)
	var familiar := autofree(load("res://godot4/actors/ships/PursuerFamiliar.tscn").instantiate()) as Node2D
	var movement := familiar.get_node("PursueMovement")
	movement.configure(familiar, owner)
	add_child(familiar)
	movement.set_physics_process(false)
	familiar.global_position = Vector2(-300, 0)
	movement.get_node("ConstantForceMovement").move(0.0, movement.force)
	for frame in 90:
		await get_tree().physics_frame
	assert(familiar.global_position.x > -300.0)
	assert(familiar.global_position.x < -75.0)
	return true

func test_pursuer_texture_and_shapeoid_launcher() -> bool:
	var familiar_scene := load("res://godot4/actors/ships/PursuerFamiliar.tscn") as PackedScene
	var familiar := autofree(familiar_scene.instantiate()) as Node2D
	assert(familiar.get_node("Sprite2D").texture.resource_path == "res://assets/sprites/alchemy/circle.png")
	var launcher_scene := load("res://godot4/actors/enemies/ShapeoidLauncher.tscn") as PackedScene
	var launcher = autofree(launcher_scene.instantiate())
	assert(launcher.shapeoid_scene.resource_path == "res://godot4/actors/enemies/Bloid.tscn")
	assert(launcher.wait_time == 6.0)
	assert(launcher.get_node("TurretFiring").wait_time == 6.0)
	assert(not launcher.get_node("Weapons/PewWeapon").enabled)
	return true

func test_turret_composes_generic_aim_behavior() -> bool:
	var turret := autofree(load("res://godot4/actors/enemies/AimTurret.tscn").instantiate()) as AimTurret
	add_child(turret)
	var behavior := turret.get_node("AimAtTarget") as ActorBehavior
	assert(behavior.actor == turret and behavior.source == turret)
	var aim := turret.get_node("AimAtTarget")
	var target := autofree(CargoShipTarget.new())
	target.global_position = Vector2(300, 200)
	target.add_to_group("Ship")
	add_child(target)
	aim.call("_physics_process", 0.0)
	assert(is_equal_approx((turret.get_node("Weapons") as Node2D).global_rotation, turret.global_position.angle_to_point(target.global_position)))
	return true

func test_turret_firing_uses_shared_behavior() -> bool:
	var turret := autofree(load("res://godot4/actors/enemies/Turret.tscn").instantiate()) as Turret
	turret.wait_time = 6.0
	turret.burst_shots = 2
	turret.burst_time = 0.25
	add_child(turret)
	var firing := turret.get_node("TurretFiring")
	var shots := [0]
	turret.tap.connect(func(_charge): shots[0] += 1)
	firing.call("_on_timeout")
	assert(shots[0] == 1 and is_equal_approx((firing.get_node("Timer") as Timer).wait_time, 0.25))
	firing.call("_on_timeout")
	assert(shots[0] == 2 and is_equal_approx((firing.get_node("Timer") as Timer).wait_time, 6.0))
	return true

func test_shapeoid_uses_physics_behavior() -> bool:
	var shapeoid := autofree(load("res://godot4/actors/enemies/Shapeoid.tscn").instantiate()) as Shapeoid
	var movement := shapeoid.get_node("ConstantForceMovement")
	assert(movement != null)
	shapeoid._direction = PI / 2
	shapeoid._move()
	assert(shapeoid.constant_force.is_equal_approx(shapeoid.speed * Vector2.RIGHT.rotated(shapeoid._direction)))
	return true

func test_pickup_variants_load() -> bool:
	for id in [&"orbiting_familiar", &"follower_familiar", &"diamond_familiar", &"throwable_familiar", &"bouncing_familiar"]:
		for duration in ["run", "game", "two_games"]:
			for suffix in ["", "_glass"]:
				var path := "res://godot4/elements/collectables/items/%s/%s_%s%s.tscn" % [id, id, duration, suffix]
				var pickup := autofree(load(path).instantiate()) as Collectable
				assert(pickup.item.id == id)
				assert(pickup.item.glass == (suffix == "_glass"))

	return true

func test_blocks_enemy_shot_then_recharges_without_blocking_friends() -> bool:
	var ship := autofree(load("res://godot4/actors/ships/Ship.tscn").instantiate()) as Ship
	ship.set_player(Player.new())
	ship.get_player().team = "A"
	var scene := load("res://godot4/actors/ships/OrbitingFamiliar.tscn") as PackedScene
	var drone := scene.instantiate() as Familiar
	drone.configure(ship, scene)
	ship.add_child(drone)
	var interception := drone.get_node("ProjectileInterception") as ProjectileInterception
	var friend := autofree(Shot.new())
	friend.set_team("A")
	interception._intercept(friend)
	assert(not friend.destroyed)
	assert(interception.recharge_left == 0.0)
	var enemy := autofree(Shot.new())
	enemy.set_team("B")
	interception._intercept(enemy)
	assert(enemy.destroyed)
	assert(interception.recharge_left == interception.recharge_seconds)
	var second := autofree(Shot.new())
	second.set_team("B")
	interception._intercept(second)
	assert(not second.destroyed)
	interception.recharge_left = 0.0
	interception._intercept(second)
	assert(second.destroyed)

	return true

func test_orbit_ignores_ship_heading() -> bool:
	var ship := autofree(load("res://godot4/actors/ships/Ship.tscn").instantiate()) as Ship
	ship.set_player(Player.new())
	var scene := load("res://godot4/actors/ships/OrbitingFamiliar.tscn") as PackedScene
	var drone := scene.instantiate() as Familiar
	drone.configure(ship, scene)
	ship.add_child(drone)
	var orbit := drone.get_node("OrbitMovement") as OrbitMovement
	orbit.angle = PI / 3
	orbit._update_position()
	var before := drone.global_position
	ship.rotation = PI / 2
	orbit._update_position()
	assert(absf(drone.global_position.x - before.x) < 0.001)
	assert(absf(drone.global_position.y - before.y) < 0.001)

	return true

func test_behavior_composition() -> bool:
	var ship := autofree(load("res://godot4/actors/ships/Ship.tscn").instantiate()) as Ship
	ship.set_player(Player.new())
	for path in ["OrbitingFamiliar", "FollowerFamiliar", "DiamondGeneratorFamiliar", "ThrowableFamiliar", "BouncingFamiliar"]:
		var scene := load("res://godot4/actors/ships/%s.tscn" % path) as PackedScene
		var familiar := scene.instantiate() as Familiar
		assert(familiar != null)
		familiar.configure(ship, scene)
		ship.add_child(familiar)
		assert(familiar.owner_ship == ship and familiar.definition == scene)
		for child in familiar.get_children():
			if child is ActorBehavior:
				assert(child.actor == familiar and child.source == ship)
			if child is FamiliarBehavior:
				assert(child.familiar == familiar and child.owner_ship == ship)
	if not ship.get_node("OrbitingFamiliar/OrbitMovement") is OrbitMovement: return false
	if not ship.get_node("OrbitingFamiliar/ProjectileInterception") is ProjectileInterception: return false
	if not ship.get_node("OrbitingFamiliar/ContactDamage") is ContactDamage: return false
	if not ship.get_node("FollowerFamiliar/FollowMovement") is FollowMovement: return false
	assert(ship.get_node("FollowerFamiliar/PewWeapon").host == ship)
	var shapeoid := autofree(load("res://godot4/actors/enemies/Shapeoid.tscn").instantiate()) as Shapeoid
	var movement := load("res://godot4/actors/behaviors/FollowMovement.tscn").instantiate() as FollowMovement
	shapeoid.add_child(movement)
	var manager := autofree(FamiliarManager.new())
	manager._configure_item_actor(shapeoid, ship, load("res://godot4/actors/enemies/Shapeoid.tscn"), 0, 1, null)
	assert(movement.actor == shapeoid and movement.source == ship and movement.follow_target == ship)
	movement._ready()
	assert(absf(shapeoid.global_position.distance_to(ship.global_position) - movement.follow_distance) < 0.001)
	return true

func test_new_familiar_behaviors() -> bool:
	var ship := autofree(load("res://godot4/actors/ships/Ship.tscn").instantiate()) as Ship
	ship.set_player(Player.new())
	var diamond_scene := load("res://godot4/actors/ships/DiamondGeneratorFamiliar.tscn") as PackedScene
	var diamond := diamond_scene.instantiate() as Familiar
	diamond.configure(ship, diamond_scene)
	ship.add_child(diamond)
	assert(diamond.get_node("FollowMovement") is FollowMovement)
	assert(diamond.get_node("PickupGenerator").pickup_scene.resource_path == "res://godot4/elements/collectables/Diamond.tscn")
	assert(is_equal_approx(diamond.get_node("PickupGenerator/Timer").wait_time, 10.0))
	var throwable_scene := load("res://godot4/actors/ships/ThrowableFamiliar.tscn") as PackedScene
	var throwable := throwable_scene.instantiate() as Familiar
	throwable.configure(ship, throwable_scene)
	ship.add_child(throwable)
	assert(throwable.get_node("FollowMovement") is FollowMovement)
	var throw_behavior := throwable.get_node("ThrowableMovement") as ThrowableMovement
	throw_behavior._on_tap(0.2)
	assert(throw_behavior.state == ThrowableMovement.State.THROWN)
	assert(not (throwable.get_node("FollowMovement") as FollowMovement).active)
	assert(throw_behavior._direction.is_equal_approx(Vector2.RIGHT.rotated(ship.global_rotation)))
	var bouncer_scene := load("res://godot4/actors/ships/BouncingFamiliar.tscn") as PackedScene
	var bouncer := bouncer_scene.instantiate() as Familiar
	bouncer.configure(ship, bouncer_scene)
	ship.add_child(bouncer)
	var bounce_behavior := bouncer.get_node("BounceMovement") as BounceMovement
	assert(bounce_behavior.speed > 0 and bounce_behavior.contact_cooldown > 0)
	var heading_variants := {}
	for i in 32:
		var heading := bounce_behavior._random_diagonal_velocity()
		assert(absf(heading.x) >= bounce_behavior.speed * 0.5 and absf(heading.y) >= bounce_behavior.speed * 0.5)
		heading_variants[roundi(rad_to_deg(heading.angle()))] = true
	assert(heading_variants.size() > 1)
	assert(bouncer.top_level)
	return true

func test_item_copies_reconcile_on_pickup_respawn_and_removal() -> bool:
	var manager := autofree(FamiliarManager.new())
	var ship := autofree(load("res://godot4/actors/ships/Ship.tscn").instantiate()) as Ship
	ship.set_player(Player.new())
	manager.held = [&"orbiting_familiar", &"orbiting_familiar", &"follower_familiar", &"follower_familiar"]
	manager._sync_item_actors(ship)
	var drones := ship.get_children().filter(func(child): return child is Familiar and child.definition.resource_path.ends_with("OrbitingFamiliar.tscn"))
	assert(drones.size() == 2)
	assert(is_equal_approx(drones[1].get_node("OrbitMovement").angle, PI))
	var followers := ship.get_children().filter(func(child): return child is Familiar and child.definition.resource_path.ends_with("FollowerFamiliar.tscn"))
	assert(followers.size() == 2)
	assert(followers[0].get_node("FollowMovement").follow_target == ship)
	assert(followers[1].get_node("FollowMovement").follow_target == followers[0])
	var orbit := drones[0].get_node("OrbitMovement") as OrbitMovement
	orbit.angle = 0.42
	manager._sync_item_actors(ship)
	assert(is_equal_approx(orbit.angle, 0.42))
	assert(ship.get_children().filter(func(child): return child is Familiar and child.definition.resource_path.ends_with("OrbitingFamiliar.tscn")).size() == 2)
	assert(ship.get_children().filter(func(child): return child is Familiar and child.definition.resource_path.ends_with("FollowerFamiliar.tscn")).size() == 2)
	manager.held.pop_back()
	manager._sync_item_actors(ship)
	assert(ship.get_children().filter(func(child): return child is Familiar and child.definition.resource_path.ends_with("FollowerFamiliar.tscn")).size() == 1)
	assert(is_equal_approx(orbit.angle, 0.42))
	manager.held.erase(&"orbiting_familiar")
	manager._sync_item_actors(ship)
	assert(ship.get_children().filter(func(child): return child is Familiar and child.definition.resource_path.ends_with("OrbitingFamiliar.tscn")).size() == 1)
	assert(is_equal_approx(orbit.angle, 0.0))
	manager.held.clear()
	manager._sync_item_actors(ship)
	assert(ship.get_children().filter(func(child): return child is Familiar).size() == 0)
	return true

func test_generic_start_reconciles() -> bool:
	var manager := autofree(FamiliarManager.new())
	var ship := autofree(load("res://godot4/actors/ships/Ship.tscn").instantiate()) as Ship
	ship.set_player(Player.new())
	manager.test_ship = ship
	manager.held = [&"orbiting_familiar"]
	assert(not manager.effects.has(&"orbiting_familiar"))
	manager._start(manager.held.duplicate(), [], ship.get_player().get_id())
	await get_tree().process_frame
	assert(ship.get_children().filter(func(child): return child is Familiar).size() == 1)
	return true
