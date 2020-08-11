tool
extends StaticBody2D

class_name Brick

var points = 1

enum TYPE { solid, diamond, gold, respawner, harmful }
export(TYPE) var type = TYPE.diamond setget set_type

signal killed

func set_type(v):
	type = v
	points = 1
	if type == TYPE.solid:
		$Graphics.modulate = Color(1,1,1,1)
	elif type == TYPE.diamond:
		$Graphics.modulate = Color('#0095c3')
	elif type == TYPE.gold:
		$Graphics.modulate = Color('#ffa700')
		points = 3
	elif type == TYPE.respawner:
		$Graphics.modulate = Color('#0dd614')
	# orange Color('#c18a2a')
	
func break(breaker):
	if type != TYPE.solid:
		emit_signal('killed', self, breaker)
		$CollisionShape2D.call_deferred('set_disabled', true)
		$Graphics.visible = false
	z_index = 100
	$BreakGlow.visible = true
	$AnimationPlayer.play("Break")
	yield($AnimationPlayer, "animation_finished")
	
	if type != TYPE.respawner and type != TYPE.solid:
		queue_free()
		return
	
	yield(get_tree().create_timer(1), "timeout")
	
	if type != TYPE.solid:
		$AnimationPlayer.play_backwards("Break")
		yield($AnimationPlayer, "animation_finished")
		$CollisionShape2D.call_deferred('set_disabled', false)
		$Graphics.visible = true
	z_index = 0
	$BreakGlow.visible = false
	$AnimationPlayer.play("Idle")
	
