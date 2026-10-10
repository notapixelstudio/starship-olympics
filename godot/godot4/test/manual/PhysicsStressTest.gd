extends SceneTree
# Headless wall-tunneling stress test for the configured 2D physics engine.
# Run: godot --headless --path godot -s res://godot4/test/manual/PhysicsStressTest.gd
# A body's center must never cross a wall edge: any frame-to-frame crossing counts as a tunnel.
# 'cruise': random spots and directions at full speed.
# 'dash': at rest 0..2 radii from a wall edge (corners included), then a sudden impulse into it,
# like a ship dashing while hugging the wall.
# 'crush': a body resting against a wall gets rammed into it by another one dashing from behind.
# 'overlap': center spawned up to one radius past the wall surface, then pushed into it, like a missile fired
# from a ship whose back is against the wall (MissileWeapon spawns it 50px behind the ship).
# Here crossing back out is the goal, so it counts the bodies that end up on the wrong side instead.

const HALF := 2000.0 # arena half-size
const BODIES := 100
const FRAMES := 240
const RADII := [10.0, 45.0] # ~missile, ~ship
const SPEEDS := [2000.0, 5000.0, 10000.0, 20000.0, 40000.0] # px/s (40000 is Rapier's default max velocity)

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var obstacles := {
		'ring': _square(HALF), # outer hollow wall, built like Wall.gd
		'ring_pill': _pill(), # diamondsnatch outer wall: many short edges, many convex slivers
		'hexagon': _regular(6, 400.0), # solid convex, like VRegularPolygon walls
		'star': _star(5, 500.0, 180.0), # concave: decomposed into convex pieces with seams
		'thin': _rect(Vector2(800, 16)), # thin bar
	}
	print('engine: ', ProjectSettings.get_setting('physics/2d/physics_engine'), ' @ ', Engine.physics_ticks_per_second, 'Hz')
	print('wall     mode    radius  speed   ccd  tunneled')
	var total := 0
	for wall in obstacles:
		for mode in ['cruise', 'dash', 'crush', 'overlap']:
			for radius in RADII:
				for speed in SPEEDS:
					for ccd in [false, true]:
						var tunneled := await _trial(wall.begins_with('ring'), obstacles[wall], mode, radius, speed, ccd)
						total += tunneled
						if tunneled > 0 or speed == SPEEDS[-1]:
							print('%-8s %-6s %6d %6d  %-4s %3d/%d' % [wall, mode, radius, speed, 'on' if ccd else 'off', tunneled, BODIES])
	print('TOTAL tunneled: ', total)
	quit()

func _trial(hollow: bool, polygon: PackedVector2Array, mode: String, radius: float, speed: float, ccd: bool) -> int:
	var world := Node2D.new()
	root.add_child(world)
	world.add_child(_wall(polygon, hollow))

	var material := PhysicsMaterial.new()
	material.friction = 0.0
	material.bounce = 1.0
	var shape := CircleShape2D.new()
	shape.radius = radius
	var bodies: Array[RigidBody2D] = []
	var pushes: Array[Vector2] = []
	var on_edge: Vector2
	var into_wall: Vector2
	for i in BODIES:
		var body := RigidBody2D.new()
		body.gravity_scale = 0.0
		body.linear_damp = 0.0
		body.physics_material_override = material
		body.collision_layer = 2
		body.collision_mask = 1 | 2 if mode == 'crush' else 1 # elsewhere walls only, so body-body hits don't mask tunneling
		body.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE if ccd else RigidBody2D.CCD_MODE_DISABLED
		var col := CollisionShape2D.new()
		col.shape = shape
		body.add_child(col)
		if mode != 'crush' or i % 2 == 0:
			# random point on a random edge, and the normal pointing into the playable side
			var e := randi() % polygon.size()
			var a := polygon[e]
			var b := polygon[(e + 1) % polygon.size()]
			on_edge = a.lerp(b, randf())
			into_wall = (b - a).orthogonal().normalized()
			if Geometry2D.is_point_in_polygon(on_edge + into_wall, polygon) == hollow: # the ring blocks the outside
				into_wall = -into_wall
		if mode == 'cruise':
			var bounds := Rect2(polygon[0], Vector2.ZERO)
			for point in polygon:
				bounds = bounds.expand(point)
			if not hollow:
				bounds = bounds.grow(1500)
			body.position = bounds.get_center()
			while not _playable(polygon, hollow, body.position, radius):
				body.position = bounds.position + bounds.size * Vector2(randf(), randf())
			body.linear_velocity = Vector2.from_angle(randf() * TAU) * speed
		elif mode == 'dash' or mode == 'overlap':
			var gap := randf_range(-2 * radius, -radius) if mode == 'overlap' else randf_range(0.0, 2 * radius)
			body.position = on_edge - into_wall * (radius + gap)
			pushes.append(into_wall.rotated(randf_range(-1.2, 1.2)) * speed)
		elif i % 2 == 0: # victim, resting on the wall
			body.position = on_edge - into_wall * (radius + 1)
			pushes.append(Vector2.ZERO)
		else: # rammer, right behind the victim
			body.position = on_edge - into_wall * (radius * 4)
			pushes.append(into_wall * speed)
		world.add_child(body)
		bodies.append(body)

	if mode != 'cruise':
		await physics_frame
		for i in BODIES:
			bodies[i].apply_central_impulse(pushes[i] * bodies[i].mass)

	var tunneled := {}
	var previous := bodies.map(func(body): return body.position)
	for f in FRAMES:
		await physics_frame
		for i in BODIES:
			if _crosses(polygon, previous[i], bodies[i].position):
				tunneled[i] = true
			previous[i] = bodies[i].position
	if mode == 'overlap':
		tunneled = {}
		for i in BODIES:
			if Geometry2D.is_point_in_polygon(bodies[i].position, polygon) != hollow:
				tunneled[i] = true
	world.free()
	await physics_frame
	return tunneled.size()

func _playable(polygon: PackedVector2Array, hollow: bool, point: Vector2, radius: float) -> bool:
	if Geometry2D.is_point_in_polygon(point, polygon) != hollow:
		return false
	for e in polygon.size():
		if point.distance_to(Geometry2D.get_closest_point_to_segment(point, polygon[e], polygon[(e + 1) % polygon.size()])) <= radius:
			return false
	return true

func _crosses(polygon: PackedVector2Array, from: Vector2, to: Vector2) -> bool:
	for e in polygon.size():
		if Geometry2D.segment_intersects_segment(from, to, polygon[e], polygon[(e + 1) % polygon.size()]) != null:
			return true
	return false

func _wall(polygon: PackedVector2Array, hollow: bool) -> StaticBody2D:
	var shape := polygon
	if hollow: # same ring polygon Wall.gd builds when hollow = true
		var offset_results := Geometry2D.offset_polygon(polygon, 100.0)
		var clipped := Geometry2D.clip_polygons(offset_results[0], polygon)
		shape = clipped[0] + PackedVector2Array([clipped[1][-1]]) + clipped[1] + PackedVector2Array([clipped[0][-1]])
	var wall := StaticBody2D.new()
	var collision := CollisionPolygon2D.new()
	collision.polygon = shape
	wall.add_child(collision)
	return wall

func _pill() -> PackedVector2Array:
	var shape := VRoundedRect.new() # same numbers as diamondsnatch_1pvez
	shape.width = 3300.0
	shape.height = 2000.0
	shape.radius = 1000.0
	shape.update()
	var points: PackedVector2Array = shape.points
	shape.free()
	return points

func _square(half: float) -> PackedVector2Array:
	return _rect(Vector2(half, half) * 2)

func _rect(size: Vector2) -> PackedVector2Array:
	var h := size / 2
	return PackedVector2Array([Vector2(-h.x, -h.y), Vector2(h.x, -h.y), Vector2(h.x, h.y), Vector2(-h.x, h.y)])

func _regular(sides: int, r: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in sides:
		points.append(Vector2.from_angle(TAU * i / sides) * r)
	return points

func _star(tips: int, outer: float, inner: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in tips * 2:
		points.append(Vector2.from_angle(PI * i / tips) * (outer if i % 2 == 0 else inner))
	return points
