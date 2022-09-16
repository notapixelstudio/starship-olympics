@tool
extends StaticBody2D

class_name Brick

@export var points := 1 :
	get:
		return points # TODOConverter40 Copy here content of get_points
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_points

enum TYPE { solid, diamond, gold, respawner, harmful, super, huge }
@export var type: TYPE = TYPE.diamond :
	get:
		return type # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_type

@export var colorize := true

signal killed

func set_type(v):
	type = v
	$CollisionShape2D.shape.extents.y = 55
	$Sprite2D/Label.visible = false
	if type == TYPE.solid:
		self.set_color(Color(0.8,0.8,0.8,1))
		$Under.texture = load('res://assets/sprites/bricks/solid_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/solid.png')
	elif type == TYPE.diamond:
		self.set_color(Color('#179be3'))
		$Under.texture = load('res://assets/sprites/bricks/diamond_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/diamond.png')
	elif type == TYPE.gold:
		self.set_color(Color('#ffa700'))
		$Under.texture = load('res://assets/sprites/bricks/gold_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/gold.png')
	elif type == TYPE.respawner:
		self.set_color(Color(0.1,0.9,0.2,1))
		$Under.texture = load('res://assets/sprites/bricks/respawner_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/respawner.png')
	elif type == TYPE.super:
		self.set_color(Color('#fff700'))
		$Under.texture = load('res://assets/sprites/bricks/gold_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/gold.png')
	elif type == TYPE.huge:
		self.set_color(Color('#fff700'))
		$Under.texture = load('res://assets/sprites/bricks/huge_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/huge.png')
		$Sprite2D/Label.visible = true
		$CollisionShape2D.shape.extents.y = 110
	# orange Color('#c18a2a')
	
	if not colorize:
		self.set_color(Color.WHITE)
	
func break(breaker):
	if type != TYPE.solid:
		if breaker:
			emit_signal('killed', self, breaker)
		$CollisionShape2D.call_deferred('set_disabled', true)
		$Under.visible = false
		$Sprite2D.visible = false
		
	$BreakGlow.visible = true
	$AnimationPlayer.play("Break")
	await $AnimationPlayer.animation_finished
	
	if type != TYPE.respawner and type != TYPE.solid:
		queue_free()
		return
	
	await get_tree().create_timer(2).timeout
	
	if type == TYPE.respawner:
		$AnimationPlayer.play_backwards("Break")
		await $AnimationPlayer.animation_finished
		$CollisionShape2D.call_deferred('set_disabled', false)
		$Under.visible = true
		$Sprite2D.visible = true
		
	$BreakGlow.visible = false
	
func get_strategy(ship, distance, game_mode):
	if game_mode.name == 'BrickBreak':
		return {"avoid": 0.1, "seek": distance/500, "shoot": 0.5}
	return {"avoid": 0.1}
	
func set_color(color):
	$Under.modulate = color
	$Sprite2D.modulate = color
	
func get_points() -> int:
	return points
	
func set_points(v: int) -> void:
	points = v
	$Sprite2D/Label.text = str(points)
