extends Area2D

onready var anim = $AnimationPlayer
onready var outline = $Ground/Outline
onready var border = $Ground/Front/Border
onready var monogram = $Ground/Front/Wrapper/Monogram

export (String) var content = null setget set_content

signal revealing_while_undetermined
signal taken
signal revealed

var locked = false

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
		
	# this should be emitted here, after the value is updated correctly
	if player != previous_player and player != null:
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
	if locked:
		return
		
	locked = true
	if author is Ship:
		set_player(author.get_player())
	reveal()

func reveal():
	if content == null:
		emit_signal('revealing_while_undetermined', self)
	anim.play("Reveal")
	yield(anim, "animation_finished")
	emit_signal("revealed")
	anim.play("Float")
	yield(get_tree().create_timer(0.3), "timeout") # wait a bit to avoid retaking a card
	locked = false

func hide():
	self.set_player(null)
	anim.play_backwards("Reveal")
	yield(anim, "animation_finished")
	
	# selection feedback lingers on
	border.visible = false
	monogram.visible = false

func equals(other_card):
	return content == other_card.content
	
func _on_Card_body_entered(body):
	if body is Ship:
		outline.visible = true
		outline.modulate = body.species.color

func _on_Card_body_exited(body):
	if body is Ship:
		outline.visible = false
		
