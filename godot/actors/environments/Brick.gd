tool
extends StaticBody2D

class_name Brick

export var respawn = false setget set_respawn

func set_respawn(v):
	respawn = v
	$ColorRect.modulate = Color('#c18a2a') if respawn else Color('#0095c3')
	$Line2D.modulate = Color('#c18a2a') if respawn else Color('#0095c3')
	
func break(breaker):
	$CollisionShape2D.call_deferred('set_disabled', true)
	z_index = 100
	$ColorRect.visible = false
	$Line2D.visible = false
	$BreakGlow.visible = true
	$AnimationPlayer.play("Break")
	yield($AnimationPlayer, "animation_finished")
	
	if not respawn:
		queue_free()
		return
	
	yield(get_tree().create_timer(1), "timeout")
	
	$AnimationPlayer.play_backwards("Break")
	yield($AnimationPlayer, "animation_finished")
	$CollisionShape2D.call_deferred('set_disabled', false)
	z_index = 0
	$ColorRect.visible = true
	$Line2D.visible = true
	$BreakGlow.visible = false
	$AnimationPlayer.play("Idle")
	
