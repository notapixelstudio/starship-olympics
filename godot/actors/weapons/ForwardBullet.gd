extends RigidBody2D

export var PfftScene : PackedScene

var ship : Ship

func _process(delta):
	$Halo.rotation = linear_velocity.angle()

func _on_ForwardBullet_body_entered(body):
	if not (body is Mirror):
		dissolve()
		queue_free()
		
	if body.has_method('damage'):
		body.damage(self, ship)

func set_ship(v : Ship):
	ship = v
	$Halo.modulate = ship.get_color()

func dissolve() -> void:
	var pfft = PfftScene.instance()
	pfft.set_color(ship.get_color())
	get_parent().add_child(pfft)
	pfft.global_position = global_position

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
