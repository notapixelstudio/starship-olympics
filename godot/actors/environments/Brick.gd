tool
extends StaticBody2D

class_name Brick

export var points := 1 setget set_points, get_points
export var strength := 1

enum TYPE { solid, diamond, gold, respawner, harmful, super, huge }
export(TYPE) var type = TYPE.diamond setget set_type

export var colorize := false

signal killed

func set_type(v):
	type = v
	$CollisionShape2D.shape.extents.y = 55
	$Sprite/Label.visible = false
	if type == TYPE.solid:
		self.set_color(Color(0.8,0.8,0.8,1))
		$Under.texture = load('res://assets/sprites/bricks/solid_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/solid.png')
	elif type == TYPE.diamond:
		self.set_color(Color('#179be3'))
		$Under.texture = load('res://assets/sprites/bricks/diamond_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/diamond.png')
	elif type == TYPE.gold:
		self.set_color(Color('#ffa700'))
		$Under.texture = load('res://assets/sprites/bricks/gold_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/gold.png')
	elif type == TYPE.respawner:
		self.set_color(Color(0.1,0.9,0.2,1))
		$Under.texture = load('res://assets/sprites/bricks/respawner_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/respawner.png')
	elif type == TYPE.super:
		self.set_color(Color('#fff700'))
		$Under.texture = load('res://assets/sprites/bricks/gold_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/gold.png')
	elif type == TYPE.huge:
		$Under.texture = load('res://assets/sprites/bricks/huge_under.png')
		$Sprite.texture = load('res://assets/sprites/bricks/huge.png')
		$Sprite/Label.visible = points > 0
		$CollisionShape2D.shape.extents.y = 110
	# orange Color('#c18a2a')
	
	if not colorize:
		self.set_color(Color('#683b15'))
	
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
	
func set_color(color):
	$Under.modulate = color
	$Sprite.modulate = color
	
func get_points() -> int:
	return points
	
func set_points(v: int) -> void:
	points = v
	$Sprite/Label.text = str(points)

func damage(hazard, damager):
	strength -= 1
	if strength <= 0:
		strength = 0
		self.break(damager)
