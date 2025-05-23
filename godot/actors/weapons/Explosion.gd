extends Area2D

class_name Explosion

@export var kilotons := 30
@onready var repeal_field_width = $RepealField/CollisionShape2D.get_shape().radius

signal end_explosion

func _ready():
	$Halo.scale.x = 0.4
	$Halo.rotation = randf()*2*PI
	
	$Spikes.rotation = randf()*2*PI
	
	SoundEffects.play($RandomAudioStreamPlayer2D)

func _on_animation_ended(name):
	emit_signal("end_explosion")
	get_parent().call_deferred("remove_child", self)
	await get_tree().create_timer(1).timeout
	call_deferred("queue_free")

func _physics_process(delta):
	for body in $RepealField.get_overlapping_bodies():
		if body is Bomb or body is Ball or body is Diamond or body is BigDiamond or body is Rock or body is PowerUp or body is Mine or body is DeadShip or body is Ship or body is Marble:
			var vec = body.global_position-global_position
			body.apply_central_impulse(vec.normalized()*global.sigmoid(vec.length(), repeal_field_width)*kilotons*(80 if body is Rock else 0.25 if body is DeadShip else 1))

func _on_RepealField_body_entered(body):
	if body is Bomb:
		ECM.E(body).get('Pursuer').set_target(null)
		var pursuer = ECM.E(body).get('Pursuer')
		pursuer.disable()
		pursuer.enable_with_timeout(1)

func get_strategy(ship, distance, game_mode):
	return {"avoid": 1}
