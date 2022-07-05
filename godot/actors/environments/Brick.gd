tool
extends StaticBody2D

class_name Brick

var points = 1

enum TYPE { solid, diamond, gold, respawner, harmful, super }
export(TYPE) var type = TYPE.diamond setget set_type

export var colorize := true

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
	elif type == TYPE.super:
		$Under.modulate = Color('#fff700')
		$Sprite.modulate = Color('#fff700')
		$Under.texture = load('res://assets/sprites/bricks/gold_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/gold.png')
		points = 10
	# orange Color('#c18a2a')
	
	if not colorize:
		$Under.modulate = Color.white
		$Sprite.modulate = Color.white
	
func break(breaker):
	if type != TYPE.solid:
		if breaker:
			emit_signal('killed', self, breaker)
		$CollisionShape2D.call_deferred('set_disabled', true)
		$Under.visible = false
		$Sprite.visible = false
		
	$BreakGlow.visible = true
	$AnimationPlayer.play("Break")
	yield($AnimationPlayer, "animation_finished")
	
	if type != TYPE.respawner and type != TYPE.solid:
		queue_free()
		return
	
	yield(get_tree().create_timer(2), "timeout")
	
	if type == TYPE.respawner:
		$AnimationPlayer.play_backwards("Break")
		yield($AnimationPlayer, "animation_finished")
		$CollisionShape2D.call_deferred('set_disabled', false)
		$Under.visible = true
		$Sprite.visible = true
		
	$BreakGlow.visible = false
	
func get_strategy(ship, distance, game_mode):
	if game_mode.name == 'BrickBreak':
		return {"avoid": 0.1, "seek": distance/500, "shoot": 0.5}
	return {"avoid": 0.1}
	
