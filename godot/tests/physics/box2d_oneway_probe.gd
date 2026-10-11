extends SceneTree
# One-way wall at y=300 (default direction blocks bodies moving down / +y).
# Body "down" moves +y: should be blocked. Body "up" moves -y: should pass through.
# Wall "custom" at x=700 has direction (1,0): blocks +x, passes -x.

var down: RigidBody2D
var up: RigidBody2D
var right: RigidBody2D
var left: RigidBody2D
var frame := 0

func _init() -> void:
	physics_frame.connect(_on_physics_frame)
	_build.call_deferred()

func _wall(pos: Vector2, size: Vector2, dir: Vector2) -> void:
	var s := StaticBody2D.new()
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new(); r.size = size
	cs.shape = r
	cs.one_way_collision = true
	if dir != Vector2(0, 1):
		cs.set("one_way_collision_direction", dir)
	s.add_child(cs); s.position = pos
	root.add_child(s)

func _ball(pos: Vector2, vel: Vector2) -> RigidBody2D:
	var b := RigidBody2D.new()
	var cs := CollisionShape2D.new(); var c := CircleShape2D.new(); c.radius = 10
	cs.shape = c; b.add_child(cs); b.position = pos
	b.gravity_scale = 0.0; b.linear_velocity = vel
	root.add_child(b)
	return b

func _build() -> void:
	_wall(Vector2(200, 300), Vector2(400, 20), Vector2(0, 1))
	_wall(Vector2(700, 300), Vector2(20, 400), Vector2(1, 0))
	down = _ball(Vector2(100, 200), Vector2(0, 300))
	up = _ball(Vector2(300, 400), Vector2(0, -300))
	right = _ball(Vector2(600, 250), Vector2(300, 0))
	left = _ball(Vector2(800, 350), Vector2(-300, 0))

func _on_physics_frame() -> void:
	if down == null:
		return
	frame += 1
	if frame >= 90:
		print("down y=%.1f blocked=%s" % [down.position.y, down.position.y < 300])
		print("up y=%.1f passed=%s" % [up.position.y, up.position.y < 300])
		print("right x=%.1f blocked=%s" % [right.position.x, right.position.x < 700])
		print("left x=%.1f passed=%s" % [left.position.x, left.position.x < 700])
		var ok := down.position.y < 300 and up.position.y < 300 and right.position.x < 700 and left.position.x < 700
		quit(0 if ok else 1)
