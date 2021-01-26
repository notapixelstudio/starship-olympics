extends Area2D

onready var anim = $AnimationPlayer
onready var outline = $Ground/Outline
onready var border = $Ground/Front/Border
onready var monogram = $Ground/Front/Wrapper/Monogram

export (String) var content = null setget set_content

signal revealing_while_undetermined

var player setget set_player, get_player

func set_player(v):
	player = v
	if player:
		border.modulate = player.species.color
		monogram.text = player.species.get_monogram()
		monogram.modulate = player.species.color
		border.visible = true
		monogram.visible = true
	else:
		border.visible = false
		monogram.visible = false
	
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
	if author is Ship:
		set_player(author.get_player())
	
	if content == null:
		emit_signal('revealing_while_undetermined', self)
	anim.play("Reveal")
	yield(anim, "animation_finished")
	anim.play("Float")
	
func _on_Card_body_entered(body):
	if body is Ship:
		outline.visible = true
		outline.modulate = body.species.color

func _on_Card_body_exited(body):
	if body is Ship:
		outline.visible = false
		
