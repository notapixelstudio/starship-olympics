extends SceneTree
# Deterministic Box2D probe: run with old and new addon binaries and diff the output.

const FRAMES := 300
var root2d: Node2D
var bodies: Array[RigidBody2D] = []
var area_hits := 0
var contact_hits := 0
var frame := 0

func _init() -> void:
	physics_frame.connect(_on_physics_frame)
	root2d = Node2D.new()
	root.add_child.call_deferred(root2d)
	_build.call_deferred()

func _static(shape: Shape2D, pos: Vector2) -> StaticBody2D:
	var s := StaticBody2D.new()
	var cs := CollisionShape2D.new()
	cs.shape = shape
	s.add_child(cs)
	s.position = pos
	root2d.add_child(s)
	return s

func _rigid(shape: Shape2D, pos: Vector2) -> RigidBody2D:
	var b := RigidBody2D.new()
	var cs := CollisionShape2D.new()
	cs.shape = shape
	b.add_child(cs)
	b.position = pos
	root2d.add_child(b)
	bodies.append(b)
	return b

func _build() -> void:
	print("engine=", ProjectSettings.get_setting("physics/2d/physics_engine"))
	# Arena: rectangle floor, segment wall, concave wall, polygon wall
	var floor_shape := RectangleShape2D.new(); floor_shape.size = Vector2(1000, 20)
	_static(floor_shape, Vector2(500, 600))
	var seg := SegmentShape2D.new(); seg.a = Vector2(0, -300); seg.b = Vector2(0, 300)
	_static(seg, Vector2(0, 300))
	var conc := ConcavePolygonShape2D.new()
	conc.segments = PackedVector2Array([Vector2(0, -300), Vector2(0, 0), Vector2(0, 0), Vector2(0, 300)])
	_static(conc, Vector2(1000, 300))
	var poly_body := StaticBody2D.new()
	var cp := CollisionPolygon2D.new()
	cp.polygon = PackedVector2Array([Vector2(-50, 0), Vector2(50, 0), Vector2(0, -40)])
	poly_body.add_child(cp); poly_body.position = Vector2(500, 590)
	root2d.add_child(poly_body)

	# Dynamic bodies
	var circle := CircleShape2D.new(); circle.radius = 15
	var box := RectangleShape2D.new(); box.size = Vector2(30, 30)
	var a := _rigid(circle, Vector2(480, 100))
	var b := _rigid(box, Vector2(520, 50))
	a.linear_velocity = Vector2(0, 400)
	a.contact_monitor = true; a.max_contacts_reported = 4
	a.body_entered.connect(func(_n): contact_hits += 1)
	b.apply_torque_impulse(500.0)
	b.constant_torque = 50.0
	b.angular_damp = 0.5

	# Pin joint pair
	var c := _rigid(circle, Vector2(300, 200))
	var d := _rigid(circle, Vector2(340, 200))
	var pin := PinJoint2D.new()
	pin.position = Vector2(320, 200)
	root2d.add_child(pin)
	pin.node_a = pin.get_path_to(c); pin.node_b = pin.get_path_to(d)
	pin.softness = 0.25
	c.linear_velocity = Vector2(0, 300)

	# Fast CCD bullet at the thin right wall (tunneling check)
	var bullet := _rigid(circle, Vector2(100, 300))
	bullet.gravity_scale = 0.0
	bullet.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	bullet.linear_velocity = Vector2(-6000, 0)

	# Area
	var area := Area2D.new()
	var acs := CollisionShape2D.new(); var ash := RectangleShape2D.new(); ash.size = Vector2(200, 100)
	acs.shape = ash; area.add_child(acs); area.position = Vector2(500, 450)
	area.body_entered.connect(func(_n): area_hits += 1)
	root2d.add_child(area)

func _on_physics_frame() -> void:
	if bodies.is_empty():
		return
	frame += 1
	var ps := PhysicsServer2D
	if frame == 1:
		var st := ps.body_get_direct_state(bodies[1].get_rid())
		print("inv_mass=%.4f inv_inertia=%.6f step=%.4f" % [st.inverse_mass, st.inverse_inertia, st.step])
		print("space_param_contact_bias=%.3f" % ps.space_get_param(root2d.get_world_2d().space, PhysicsServer2D.SPACE_PARAM_CONTACT_DEFAULT_BIAS))
		bodies[1].angular_velocity = 3.0
	if frame % 30 == 0:
		var line := "f%03d" % frame
		for b in bodies:
			line += " (%.1f,%.1f r%.2f w%.2f)" % [b.position.x, b.position.y, b.rotation, b.angular_velocity]
		print(line)
		var q := PhysicsRayQueryParameters2D.create(Vector2(500, 0), Vector2(500, 700))
		var hit := root2d.get_world_2d().direct_space_state.intersect_ray(q)
		print("  ray=", "none" if hit.is_empty() else "%.1f,%.1f" % [hit.position.x, hit.position.y])
	if frame >= FRAMES:
		print("bullet_x=%.1f (wall at 0, tunneled=%s)" % [bodies[4].position.x, bodies[4].position.x < 0])
		print("const_torque=%.2f area_hits=%d contact_hits=%d" % [bodies[1].constant_torque, area_hits, contact_hits])
		quit()
