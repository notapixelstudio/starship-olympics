extends SceneTree
# Corner-shot stress test on deathmatch/pvp/2p.tscn:
# put P1 in each arena corner with its rear toward the vertex, fire a full-charge missile
# (real Ship.do_charge/do_release + MissileWeapon), and check the missile stays inside the arena.

const SCENE := "res://godot4/minigames/deathmatch/pvp/2p.tscn"
const DISTANCES := [45.0, 55.0, 70.0, 90.0]
const ANGLE_OFFSETS_DEG := [-45, -30, -15, 0, 15, 30, 45]
const SETTLE_FRAMES := 3
const TRACK_FRAMES := 180

var arena: Node
var ship: RigidBody2D
var other: RigidBody2D
var p1
var homing := OS.get_environment("HOMING") != "0"
var inner := PackedVector2Array()
var trials: Array = []
var trial_i := -1
var phase := &"boot"
var phase_frame := 0
var tracked := {}  # missile instance id -> {escaped, max_out}
var t_missiles := 0
var t_escaped := 0
var t_ship_out := false
var tot_trials := 0
var tot_missiles := 0
var tot_escaped := 0
var tot_ship_out := 0
var tot_bounces := 0

func _init() -> void:
	physics_frame.connect(_tick)
	_boot.call_deferred()

func _boot() -> void:
	arena = load(SCENE).instantiate()
	root.add_child(arena)

func _ready_ships() -> bool:
	var ships := get_nodes_in_group("Ship")
	if ships.size() < 2:
		return false
	p1 = ships[0].get_player()
	_refresh_ships()
	var wall := arena.find_child("OutsideWall", true, false)
	for p in wall._polygon:
		inner.append(wall.global_transform * p)
	print("engine=", ProjectSettings.get_setting("physics/2d/physics_engine"), " homing=", homing, " weapon=",
		ship.find_children("*", "MissileWeapon", true, false).size() > 0, " inner_vertices=", inner.size())
	var n := inner.size()
	for vi in n:
		var v: Vector2 = inner[vi]
		var to_prev := (inner[(vi - 1 + n) % n] - v).normalized()
		var to_next := (inner[(vi + 1) % n] - v).normalized()
		var bisector := (to_prev + to_next).normalized()  # points into the arena
		if not Geometry2D.is_point_in_polygon(v + bisector * 5.0, inner):
			bisector = -bisector
		for d in DISTANCES:
			for off in ANGLE_OFFSETS_DEG:
				trials.append({"v": vi, "d": d, "off": off, "pos": v + bisector * d,
					"rot": bisector.angle() + deg_to_rad(off)})
	return true

func _refresh_ships() -> bool:
	ship = null; other = null
	for s in get_nodes_in_group("Ship"):
		if not is_instance_valid(s) or s.is_queued_for_deletion() or not s.is_inside_tree():
			continue
		if s.get_player() == p1: ship = s
		else: other = s
	return ship != null

func _place(body: RigidBody2D, pos: Vector2, rot: float) -> void:
	PhysicsServer2D.body_set_state(body.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(rot, pos))
	PhysicsServer2D.body_set_state(body.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	PhysicsServer2D.body_set_state(body.get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)

func _missiles() -> Array:
	return arena.find_children("*", "Missile", true, false)

func _outside_dist(p: Vector2) -> float:
	if Geometry2D.is_point_in_polygon(p, inner):
		return 0.0
	var best := INF
	var n := inner.size()
	for i in n:
		var c: Vector2 = Geometry2D.get_closest_point_to_segment(p, inner[i], inner[(i + 1) % n])
		best = min(best, p.distance_to(c))
	return best

func _tick() -> void:
	phase_frame += 1
	match phase:
		&"boot":
			if arena == null or phase_frame < 5:
				return
			if phase_frame == 5:
				var events := root.get_node("Events")
				for p in arena.players:
					events.player_ready.emit(p)
				events.battle_start.emit()
				return
			if _ready_ships():
				_next_trial()
			elif phase_frame > 300:
				print("FAILED: ships never spawned"); quit(1)
		&"wait_ship":
			if _refresh_ships():
				_start_trial()
			elif phase_frame > 600:
				print("FAILED: P1 never respawned"); quit(1)
		&"settle":
			if phase_frame >= SETTLE_FRAMES:
				ship.do_charge()
				ship.get_node("%ChargeManager")._charge = 1.0  # full charge
				ship.do_release()
				phase = &"track"; phase_frame = 0
		&"track":
			for m in _missiles():
				var id: int = m.get_instance_id()
				if not tracked.has(id):
					tracked[id] = {"max_out": 0.0, "bounces": 0, "frames": 0, "v": m.linear_velocity}
					if not homing: m._homing = false
				tracked[id].max_out = max(tracked[id].max_out, _outside_dist(m.global_position))
				tracked[id].frames += 1
				if m.linear_velocity.dot(tracked[id].v) < 0.0 or m.linear_velocity.angle_to(tracked[id].v) > 0.8:
					tracked[id].bounces += 1
				tracked[id].v = m.linear_velocity
			if is_instance_valid(ship) and _outside_dist(ship.global_position) > 0.0:
				t_ship_out = true
			if phase_frame >= TRACK_FRAMES:
				_finish_trial()
				_next_trial()

func _finish_trial() -> void:
	var t: Dictionary = trials[trial_i]
	t_missiles = tracked.size()
	t_escaped = 0
	var worst := 0.0
	var bounces := 0
	var frames := 0
	for k in tracked:
		bounces += tracked[k].bounces; frames += tracked[k].frames
		worst = max(worst, tracked[k].max_out)
		if tracked[k].max_out > 0.0:
			t_escaped += 1
	tot_trials += 1; tot_missiles += t_missiles; tot_escaped += t_escaped; tot_bounces += bounces
	if t_ship_out: tot_ship_out += 1
	print("v%d d%.0f a%+d missiles=%d escaped=%d worst_out=%.0f ship_out=%s bounces=%d alive=%d" % [t.v, t.d, t.off, t_missiles, t_escaped, worst, t_ship_out, bounces, frames])

func _next_trial() -> void:
	for m in _missiles():
		m.queue_free()
	tracked.clear(); t_ship_out = false
	trial_i += 1
	if trial_i >= trials.size():
		print("SUMMARY trials=%d missiles=%d escaped=%d ship_out=%d bounces=%d" % [tot_trials, tot_missiles, tot_escaped, tot_ship_out, tot_bounces])
		quit()
		return
	phase = &"wait_ship"; phase_frame = 0

func _start_trial() -> void:
	var t: Dictionary = trials[trial_i]
	if other: _place(other, Vector2.ZERO, 0.0)
	_place(ship, t.pos, t.rot)
	phase = &"settle"; phase_frame = 0
