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
		$Under.modulate = Color(0.8,0.8,0.8,1)
		$Sprite.modulate = Color(0.8,0.8,0.8,1)
		$Under.texture = load('res://assets/sprites/bricks/solid_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/solid.png')
	elif type == TYPE.diamond:
		$Under.modulate = Color('#179be3')
		$Sprite.modulate = Color('#179be3')
		$Under.texture = load('res://assets/sprites/bricks/diamond_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/diamond.png')
	elif type == TYPE.gold:
		$Under.modulate = Color('#ffa700')
		$Sprite.modulate = Color('#ffa700')
		$Under.texture = load('res://assets/sprites/bricks/gold_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/gold.png')
		points = 3
	elif type == TYPE.respawner:
		$Under.modulate = Color(0.1,0.9,0.2,1)
		$Sprite.modulate = Color(0.1,0.9,0.2,1)
		$Under.texture = load('res://assets/sprites/bricks/respawner_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/respawner.png')
		
	# orange Color('#c18a2a')
	
func break(breaker):
	if type != TYPE.solid:
		emit_signal('killed', self, breaker)
		$CollisionShape2D.call_deferred('set_disabled', true)
		$Under.visible = false
		$Sprite.visible = false
	z_index = 100
	$BreakGlow.visible = true
	$AnimationPlayer.play("Break")
	yield($AnimationPlayer, "animation_finished")
	
	if type != TYPE.respawner and type != TYPE.solid:
		queue_free()
		return
	
	yield(get_tree().create_timer(1), "timeout")
	
	if type == TYPE.respawner:
		$AnimationPlayer.play_backwards("Break")
		yield($AnimationPlayer, "animation_finished")
		$CollisionShape2D.call_deferred('set_disabled', false)
		$Under.visible = true
		$Sprite.visible = true
	z_index = 0
	$BreakGlow.visible = false
	
