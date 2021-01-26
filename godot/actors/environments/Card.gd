extends Area2D

onready var anim = $AnimationPlayer
onready var outline = $Ground/Outline

export var content = 'animals/a00' setget set_content

signal revealing

func set_content(v):
	content = v
	refresh_texture()
	
func _ready():
	refresh_texture()
	
func refresh_texture():
	$Ground/Front/Figure.texture = load('res://assets/sprites/' + content + '.png')

func _on_tap(author):
	emit_signal('revealing', self)
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
		
