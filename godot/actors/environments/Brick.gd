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
	$Graphics/BrickLines.visible = true
	$Graphics/SolidFill.visible = false
	$Graphics/RespawnerLine.visible = false
	$Graphics/Border.joint_mode = Line2D.LINE_JOINT_SHARP
	if type == TYPE.solid:
		$Graphics.modulate = Color(0.7,0.7,0.7,1)
		$Graphics/BrickLines.visible = false
		$Graphics/SolidFill.visible = true
	elif type == TYPE.diamond:
		$Graphics.modulate = Color('#2b839e')#0095c3')
	elif type == TYPE.gold:
		$Graphics.modulate = Color('#ffa700')
		$Graphics/Border.joint_mode = Line2D.LINE_JOINT_BEVEL
		points = 3
	elif type == TYPE.respawner:
		$Graphics.modulate = Color('#27b01b')#0dd614')
		$Graphics/BrickLines.visible = false
		$Graphics/RespawnerLine.visible = true
		$Graphics/Border.joint_mode = Line2D.LINE_JOINT_ROUND
	# orange Color('#c18a2a')
	
func break(breaker):
	if type != TYPE.solid:
		emit_signal('killed', self, breaker)
		$CollisionShape2D.call_deferred('set_disabled', true)
		$Graphics.visible = false
	z_index = 100
	$BreakGlow.visible = true
	$AnimationPlayer.play("Break")
	$GravitonField.call_deferred('set_enabled', true)
	yield($AnimationPlayer, "animation_finished")
	
	if type != TYPE.respawner and type != TYPE.solid:
		queue_free()
		return
	
	$GravitonField.enabled = false
	
	yield(get_tree().create_timer(1), "timeout")
	
	if type == TYPE.respawner:
		$AnimationPlayer.play_backwards("Break")
		$GravitonField.enabled = true
		$GravitonField.multiplier = -$GravitonField.multiplier
		yield($AnimationPlayer, "animation_finished")
		$GravitonField.enabled = false
		$GravitonField.multiplier = $GravitonField.multiplier
		$CollisionShape2D.call_deferred('set_disabled', false)
		$Graphics.visible = true
	z_index = 0
	$BreakGlow.visible = false
	
