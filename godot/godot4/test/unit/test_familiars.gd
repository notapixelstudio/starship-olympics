extends GutTest

const ARENA := preload("res://godot4/test/manual/TestFamiliars.tscn")


func test_formation_alternates_sides_and_staggers_rows() -> void:
	var follow: FollowMovement = autofree(load("res://godot4/actors/behaviors/FollowMovement.tscn").instantiate())
	assert_eq(follow.local_slot(0), Vector2(-200, 120), "first slot: right")
	assert_eq(follow.local_slot(1), Vector2(-200, -120), "second slot: mirrored left")
	assert_eq(follow.local_slot(2), Vector2(-360, 160), "second row: further back and out")
	assert_eq(follow.local_slot(3), Vector2(-360, -160))
	assert_eq(follow.local_slot(4), Vector2(-520, 120), "third row: back in")


func test_orbit_rings_hold_2_then_4_then_6_slots() -> void:
	var orbit: OrbitMovement = autofree(load("res://godot4/actors/behaviors/OrbitMovement.tscn").instantiate())
	for index in 12:
		var ring := 0 if index < 2 else 1 if index < 6 else 2
		assert_almost_eq(orbit.slot_offset(index, 0.0).length(), orbit.orbit_radius + ring * orbit.ring_gap, 0.01, "slot %d on ring %d" % [index, ring])
	assert_almost_eq(orbit.slot_offset(0, 0.0) + orbit.slot_offset(1, 0.0), Vector2.ZERO, Vector2.ONE * 0.01, "inner pair faces each other")
	assert_almost_eq(orbit.slot_offset(2, 0.0).angle_to(orbit.slot_offset(3, 0.0)), PI / 2, 0.01, "outer ring spreads 4 slots evenly")


func test_orbit_rings_spin_opposite_ways() -> void:
	var orbit: OrbitMovement = autofree(load("res://godot4/actors/behaviors/OrbitMovement.tscn").instantiate())
	assert_gt(orbit.slot_offset(0, 0.0).angle_to(orbit.slot_offset(0, 0.1)), 0.0, "inner ring clockwise")
	assert_lt(orbit.slot_offset(2, 0.0).angle_to(orbit.slot_offset(2, 0.1)), 0.0, "next ring counter-clockwise")
	assert_gt(orbit.slot_offset(6, 0.0).angle_to(orbit.slot_offset(6, 0.1)), 0.0, "third ring clockwise again")


func test_item_manager_hands_out_slots_per_group() -> void:
	var arena: Node = add_child_autofree(ARENA.instantiate())
	await wait_until(func(): return _find_ship(arena) != null, 5.0)
	var ship := _find_ship(arena)
	assert_not_null(ship, "the arena spawned a ship")
	var battlefield: Node = arena.get_node("%Battlefield")
	for pickup in ["FollowerPickup", "GuardianPickup", "FollowerCopyPickup", "GuardianCopyPickup", "GuardianGlassPickup", "ThrowablePickup"]:
		arena.get_node("%ArenaScope").item_obtained.emit(battlefield.get_node(pickup).item, ship.get_player())
	await wait_physics_frames(2)
	var slots := {}
	for familiar in battlefield.get_children().filter(func(n): return n is Familiar):
		assert_eq(familiar.leader, ship, "%s is led by the ship" % familiar.describe())
		slots[familiar.slot_group] = slots.get(familiar.slot_group, []) + [familiar.slot_index]
	for group in slots:
		slots[group].sort()
	assert_eq(slots.get(&"formation"), [0, 1, 2], "followers and thrower share the formation")
	assert_eq(slots.get(&"orbit"), [0, 1, 2], "orbiters count on their own")
	assert_true(ship.get_node_or_null(^"FamiliarManager") is FamiliarManager, "the ship got a FamiliarManager for its familiars")
	_ignore_arena_warnings()


func test_owner_ship_is_null_once_the_ship_is_freed() -> void:
	var familiar: Familiar = autofree(load("res://godot4/actors/ships/OrbitingFamiliar.tscn").instantiate())
	var ship: Ship = load("res://godot4/actors/ships/Ship.tscn").instantiate()
	familiar.leader = ship
	assert_eq(familiar.get_owner_ship(), ship)
	ship.free()
	assert_null(familiar.get_owner_ship())


func test_pew_hit_jams_the_turret_for_a_while() -> void:
	var turret: Turret = _in_arena_scope(load("res://godot4/actors/enemies/Turret.tscn").instantiate())
	var firing: Node = turret.get_node("TurretFiring")
	turret.jam_time = 0.2
	turret.hit()
	assert_eq(firing.process_mode, Node.PROCESS_MODE_DISABLED, "jammed: firing paused")
	await wait_seconds(0.6)
	assert_eq(firing.process_mode, Node.PROCESS_MODE_INHERIT, "firing resumes")
	assert_eq(turret.modulate, Color.WHITE, "back to its color")


func test_turret_ignores_its_own_pews() -> void:
	var turret: Turret = _in_arena_scope(load("res://godot4/actors/enemies/Turret.tscn").instantiate())
	var pew: Pew = autofree(load("res://godot4/elements/projectiles/Pew.tscn").instantiate())
	pew.set_player(turret.get_player())
	turret._on_body_entered(pew)
	assert_eq(turret.get_node("TurretFiring").process_mode, Node.PROCESS_MODE_INHERIT)


func test_shapeoids_are_everyones_target() -> void:
	var weapon: Node = autofree(load("res://godot4/actors/ships/weapons/PewWeapon.tscn").instantiate())
	var turret: Turret = autofree(load("res://godot4/actors/enemies/Turret.tscn").instantiate())
	var bloid: Node = _in_arena_scope(load("res://godot4/actors/enemies/Bloid.tscn").instantiate())
	assert_true(weapon.is_valid_target(bloid, turret))


func test_aim_assist_off_ignores_targets() -> void:
	var weapon: Node = autofree(load("res://godot4/actors/ships/weapons/PewWeapon.tscn").instantiate())
	weapon.aim_assist = false
	assert_null(weapon.get_aim_compensation_target())


## Adds [param node] under a bare ArenaScope, for actors that only need the scope to be there.
func _in_arena_scope(node: Node) -> Node:
	var arena: Node = add_child_autofree(Node.new())
	var scope := ArenaScope.new()
	scope.name = "ArenaScope"
	arena.add_child(scope)
	arena.add_child(node)
	return node


## Loading the whole arena raises these harmless engine warnings; anything else still fails the test.
func _ignore_arena_warnings() -> void:
	for error in get_errors():
		if error.contains_text("Camera2D overridden") or error.contains_text("non-equal opposite anchors"):
			error.handled = true


func _find_ship(node: Node) -> Ship:
	if node is Ship:
		return node
	for child in node.get_children():
		var ship := _find_ship(child)
		if ship != null:
			return ship
	return null
