extends Area2D

class_name Explosion

onready var repeal_field_width = $RepealField/CollisionShape2D.get_shape().radius

signal end_explosion
var explosions = ["res://assets/audio/gameplay/explosions//SFX_Explosion_05.wav", "res://assets/audio/gameplay/explosions//SFX_Explosion_08.wav"]

func _ready():
	$Halo.scale.x = 1 - randf()*0.6
	$Halo.rotation = randf()*2*PI
	
	$Spikes.rotation = randf()*2*PI
	
	var index_explosion = randi() % len(explosions)
	get_node("sound").stream = load(explosions[index_explosion])
	get_node("sound").play()
	
func _on_animation_ended(name):
	emit_signal("end_explosion")
	get_parent().call_deferred("remove_child", self)
	yield(get_tree().create_timer(1), "timeout")
	call_deferred("queue_free")
	
func _physics_process(delta):
	for body in $RepealField.get_overlapping_bodies():
		if body is Bomb or body is Crown or body is Diamond or body is BigDiamond:
			var vec = body.position-position
			body.apply_central_impulse(vec.normalized()*global.sigmoid(vec.length(), repeal_field_width)*30)
			
func _on_RepealField_body_entered(body):
	if body is Bomb:
		ECM.E(body).get('Pursuer').set_target(null)
		ECM.E(body).get('Pursuer').disable()
		yield(get_tree().create_timer(1), "timeout")
		ECM.E(body).get('Pursuer').enable()
		