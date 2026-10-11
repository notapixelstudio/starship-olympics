class_name RepealField extends Area2D

@onready var _ctx = ArenaScope.get_scope(self)

func _physics_process(delta):
	for body in get_overlapping_bodies():
		var vec = body.global_position-global_position
		var radius = %CollisionShape2D.get_shape().radius
		body.apply_central_force(vec.normalized()*Utils.sigmoid(vec.length(), radius)*3000.0)

func _on_body_entered(body: Node2D) -> void:
	_ctx.collision.emit(body, self)
