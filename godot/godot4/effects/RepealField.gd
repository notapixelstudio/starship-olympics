class_name RepealField extends Area2D

@export var radius := 350.0 : set = set_radius
@onready var _ctx = ArenaScope.get_scope(self)

func set_radius(v:float) -> void:
	radius = v
	%CollisionShape2D.get_shape().radius = radius

func _physics_process(delta):
	for body in get_overlapping_bodies():
		var vec = body.global_position-global_position
		body.apply_central_force(vec.normalized()*Utils.sigmoid(vec.length(), radius)*3000.0)

func _on_body_entered(body: Node2D) -> void:
	_ctx.collision.emit(body, self)

func send_shockwave(author=null) -> void:
	for body in get_overlapping_bodies():
		if body.has_method('kill'):
			body.kill(author)
