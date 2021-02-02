extends Area2D

onready var anim = $AnimationPlayer
onready var outline = $Ground/Outline
onready var border = $Ground/Front/Border
onready var background = $Ground/Front/Background
onready var monogram = $Ground/Front/Wrapper/Monogram
onready var timer = $Timer

export (String) var content = null setget set_content, get_content

export var auto_flip_back = false setget set_auto_flip_back
export var take_ownership = false

signal revealing_while_undetermined
signal taken
signal revealed

var selected = false
var flipping = false
var face_down = true

var player setget set_player, get_player
var ship
var character_player

func set_player(v):
	var previous_player = player
	player = v
	
	if take_ownership:
		if player != null:
			border.modulate = player.species.color
			monogram.text = player.species.get_monogram()
			monogram.modulate = player.species.color
			border.visible = true
			monogram.visible = true
			selected = true
		else:
			blur()
	
	# this should be emitted here, after the value is updated correctly
	if player != previous_player and player != null:
		emit_signal('taken', self, v, ship)
	
func get_player():
	return player

func set_content(v):
	content = v
	refresh_texture()
	
func get_content():
	return content
	
func set_character_player(v):
	character_player = v
	if character_player != null:
		$Ground/Front/Character.visible = true
		$Ground/Front/Circle.visible = true
		$Ground/Front/Border.visible = true
		$Ground/Front/TopLeft.visible = true
		
		$Ground/Front/Background.self_modulate = Color(0.7,0.7,0.7)
		$Ground/Front/TopLeft/Monogram.self_modulate = Color(0.7,0.7,0.7)
		
		$Ground/Front/Background.modulate = character_player.species.color
		$Ground/Front/TopLeft/Monogram.modulate = character_player.species.color
		
		$Ground/Front/Character.texture = character_player.species.character_ok
		$Ground/Front/TopLeft/Monogram.text = character_player.species.get_monogram()
		
func get_character_player():
	return character_player
	
func _ready():
	refresh_texture()
	
func refresh_texture():
	if content:
		$Ground/Front/Figure.texture = load('res://assets/sprites/' + content + '.png')
	else:
		$Ground/Front/Figure.texture = null

func _on_tap(author):
	# no retaking
	if not face_down or flipping:
		return
		
	flipping = true
	if author is Ship:
		ship = author
		set_player(author.get_player())
	reveal()

func reveal():
	face_down = false
	if content == null:
		emit_signal('revealing_while_undetermined', self)
	anim.play("Reveal")
	yield(anim, "animation_finished")
	flipping = false
	emit_signal("revealed")
	anim.play("Float")
	
	if auto_flip_back:
		# reflip after 4 seconds
		timer.start(4)
	
func deselect():
	selected = false
	
func blur():
	border.visible = false
	monogram.visible = false
	
func hide():
	timer.stop()
	if face_down:
		return
		
	flipping = true
	face_down = true
	self.set_player(null)
	selected = false
	anim.play_backwards("Reveal")
	yield(anim, "animation_finished")
	flipping = false

func equals(other_card):
	return content == other_card.content
	
func set_tint(color):
	$Ground/Front/Background.modulate = color
	
func _on_Card_body_entered(body):
	if face_down and body is Ship:
		outline.visible = true
		outline.modulate = body.species.color

func _on_Card_body_exited(body):
	if body is Ship:
		outline.visible = false
		
func _on_Timer_timeout():
	hide()

func set_auto_flip_back(v):
	auto_flip_back = v
	if not auto_flip_back:
		timer.stop()
		
func show_mark(v):
	$Ground/Front/Wrapper/Monogram.visible = true
	$Ground/Front/Wrapper/Monogram.text = str(v)
	
