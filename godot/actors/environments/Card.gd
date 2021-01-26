extends Area2D

onready var anim = $AnimationPlayer
onready var outline = $Ground/Outline

export (String) var content = null setget set_content

signal revealing_while_undetermined

func set_content(v):
	content = v
	refresh_texture()
	
func _ready():
	refresh_texture()
	
func refresh_texture():
	if content:
		$Ground/Front/Figure.texture = load('res://assets/sprites/' + content + '.png')

func _on_tap(author):
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
		
