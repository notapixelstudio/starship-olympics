extends SceneTree
# TestCollisions stress: full-charge ship dashes into every wall edge of the thin-wall test chamber,
# from several angles/distances. A trial "tunnels" if the ship's path ever crosses into a wall polygon.

const SCENE := "res://godot4/test/manual/TestCollisions.tscn"
const DISTANCES := [120.0, 300.0]
const ANGLE_OFFSETS_DEG := [-60, -40, -20, 0, 20, 40, 60]
const TRACK_FRAMES := 60

var scene: Node
var ship: RigidBody2D
var walls: Array[PackedVector2Array] = []
var trials: Array = []
var trial_i := -1
var phase := &"boot"
var phase_frame := 0
var prev_pos := Vector2.ZERO
var crossed := false
var max_speed := 0.0
var tot_tunneled := 0

func _init() -> void:
	physics_frame.connect(_tick)
	_boot.call_deferred()

func _boot() -> void:
	scene = load(SCENE).instantiate()
	root.add_child(scene)

func _inside_any(p: Vector2) -> bool:
	for w in walls:
		if Geometry2D.is_point_in_polygon(p, w):
			return true
	return false

func _setup() -> void:
	var ships := get_nodes_in_group("Ship")
	ship = ships[0]
	for s in ships.slice(1):
		PhysicsServer2D.body_set_state(s.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(0, Vector2(-200, 600)))
	for cp in scene.find_children("*", "CollisionPolygon2D", true, false):
		if cp.get_parent() is StaticBody2D and cp.get_parent().get_parent() == scene:
			var g := PackedVector2Array()
			for p in cp.polygon:
				g.append(cp.global_transform * p)
			walls.append(g)
	for wi in walls.size():
		var w := walls[wi]
		var n := w.size()
		for i in n:
			var a: Vector2 = w[i]; var b: Vector2 = w[(i + 1) % n]
			if a.distance_to(b) < 40.0:
				continue
			var m := (a + b) * 0.5
			var normal := (b - a).orthogonal().normalized()
			if Geometry2D.is_point_in_polygon(m + normal * 2.0, w):
				normal = -normal
			for d in DISTANCES:
				var start: Vector2 = m + normal * d
				if _inside_any(start) or _inside_any(m + normal * 45.0):
					continue
				for off in ANGLE_OFFSETS_DEG:
					trials.append({"w": wi, "e": i, "d": d, "off": off, "pos": start,
						"rot": (-normal).angle() + deg_to_rad(off)})
	print("engine=", ProjectSettings.get_setting("physics/2d/physics_engine"), " walls=", walls.size(), " trials=", trials.size())

func _tick() -> void:
	phase_frame += 1
	match phase:
		&"boot":
			if phase_frame == 10:
				_setup(); _next_trial()
		&"settle":
			if phase_frame >= 3:
				ship.do_charge()
				ship.get_node("%ChargeManager")._charge = 1.0
				ship.do_release()
				prev_pos = ship.global_position
				phase = &"track"; phase_frame = 0
		&"track":
			var p := ship.global_position
			max_speed = max(max_speed, ship.linear_velocity.length())
			for w in walls:
				if not Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([prev_pos, p]), w).is_empty():
					crossed = true
			prev_pos = p
			if phase_frame >= TRACK_FRAMES:
				var t: Dictionary = trials[trial_i]
				if crossed:
					tot_tunneled += 1
					print("TUNNEL w%d e%d d%.0f a%+d" % [t.w, t.e, t.d, t.off])
				_next_trial()

func _next_trial() -> void:
	crossed = false
	trial_i += 1
	if trial_i >= trials.size():
		print("SUMMARY trials=%d tunneled=%d max_speed=%.0f" % [trials.size(), tot_tunneled, max_speed])
		quit(0 if tot_tunneled == 0 else 1)
		return
	var t: Dictionary = trials[trial_i]
	PhysicsServer2D.body_set_state(ship.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(t.rot, t.pos))
	PhysicsServer2D.body_set_state(ship.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	PhysicsServer2D.body_set_state(ship.get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)
	phase = &"settle"; phase_frame = 0
