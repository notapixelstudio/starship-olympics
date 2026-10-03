@tool
extends StaticBody2D

class_name Brick

@export var points := 1: get = get_points, set = set_points
@export var strength := 1
@export_enum(&'small', &'large') var size : String = &'large' : set = set_size
@export var content_scene : PackedScene
@export var rare_content_scene : PackedScene
@export var content_probability := 0.25
@export var rare_content_probability := 0.05

@export_enum(&'solid', &'diamond', &'gold', &'respawner', &'harmful', &'super', &'huge') var type : String = &'diamond' : set = set_type

@export var colorize := false

signal killed

var content = null

func set_size(v):
	size = v
	_refresh()
	
func set_type(v):
	type = v
	_refresh()
	
func destroy(breaker):
	if type != &'solid':
		if breaker:
			emit_signal('killed', self, breaker)
		$CollisionShape2D.call_deferred('set_disabled', true)
		$Under.visible = false
		$Sprite2D.visible = false
		
	$BreakGlow.visible = true
	$AnimationPlayer.play("Break")
	await $AnimationPlayer.animation_finished
	
	if type != &'respawner' and type != &'solid':
		queue_free()
		if content:
			content.global_position = global_position
			if content.has_method('set_appear'):
				content.set_appear(false)
			get_parent().add_child(content)
		return
	
	await get_tree().create_timer(2).timeout
	
	if type == &'respawner':
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

func hit(hitter):
	damage(1, hitter)
	assert(hitter is Ball)
	hitter.push(1000)

func damage(hazard, damager):
	strength -= 1
	if strength <= 0:
		strength = 0
		self.destroy(damager)
	else:
		if strength == 2:
			$Under.texture = load('res://assets/sprites/bricks/huge_under_1_dmg.png')
			$Sprite2D.texture = load('res://assets/sprites/bricks/huge_1_dmg.png')
		elif strength == 1:
			$Under.texture = load('res://assets/sprites/bricks/huge_under_2_dmg.png')
			$Sprite2D.texture = load('res://assets/sprites/bricks/huge_2_dmg.png')
		
		$AnimationPlayer.play("Damage")
		
		if content:
			$Content.visible = true

func _ready():
	var flip := randf() > 0.5
	if flip and not Engine.is_editor_hint():
		$Sprite2D.scale.x = -1
		$Sprite2D/Label.scale.x = -1
		$Under.scale.x = -1
		
	if content_scene:
		if randf() < content_probability:
			content = content_scene.instantiate()
			$Content.texture = content.get_texture()
			$Content.position = content.get_sprite_position()
			
	if rare_content_scene:
		if randf() < rare_content_probability:
			content = rare_content_scene.instantiate()
			$Content.texture = content.get_texture()
			$Content.position = content.get_sprite_position()
			
	_refresh()
	
func _refresh():
	$CollisionShape2D.shape.size.y = 55
	$Sprite2D/Label.visible = false
	if type == &'solid':
		self.set_color(Color(0.8,0.8,0.8,1))
		$Under.texture = load('res://assets/sprites/bricks/solid_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/solid.png')
	elif type == &'diamond':
		self.set_color(Color('#179be3'))
		$Under.texture = load('res://assets/sprites/bricks/diamond_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/diamond.png')
	elif type == &'gold':
		self.set_color(Color('#ffa700'))
		$Under.texture = load('res://assets/sprites/bricks/gold_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/gold.png')
	elif type == &'respawner':
		self.set_color(Color(0.1,0.9,0.2,1))
		$Under.texture = load('res://assets/sprites/bricks/respawner_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/respawner.png')
	elif type == &'super':
		self.set_color(Color('#fff700'))
		$Under.texture = load('res://assets/sprites/bricks/gold_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/gold.png')
	
	if size == &'large':
		$Under.texture = load('res://assets/sprites/bricks/huge_under.png')
		$Sprite2D.texture = load('res://assets/sprites/bricks/huge.png')
		$Sprite2D/Label.visible = points > 0
		$CollisionShape2D.shape.size.y = 110
	# orange Color('#c18a2a')
	
	if not colorize:
		self.set_color(Color('#683b15'))
