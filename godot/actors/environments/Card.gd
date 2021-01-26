extends Area2D

onready var anim = $AnimationPlayer
onready var outline = $Ground/Outline
onready var border = $Ground/Front/Border
onready var monogram = $Ground/Front/Wrapper/Monogram
onready var timer = $Timer

export (String) var content = null setget set_content

signal revealing_while_undetermined
signal taken
signal revealed

var last_taken_t : float

var selected = false
var flipping = false
var face_down = true

var player setget set_player, get_player

func set_player(v):
	var previous_player = player
	player = v
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
		last_taken_t = OS.get_ticks_msec()
		emit_signal('taken', self, v)
	
func get_player():
	return player

func set_content(v):
	content = v
	refresh_texture()
	
func _ready():
	refresh_texture()
	
func refresh_texture():
	if content:
		$Ground/Front/Figure.texture = load('res://assets/sprites/' + content + '.png')

func _on_tap(author):
	# no retaking
	if not face_down or flipping:
		return
		
	flipping = true
	if author is Ship:
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
	
func _on_Card_body_entered(body):
	if face_down and body is Ship:
		outline.visible = true
		outline.modulate = body.species.color

func _on_Card_body_exited(body):
	if body is Ship:
		outline.visible = false
		
func _on_Timer_timeout():
	hide()
