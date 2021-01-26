extends Area2D

onready var anim = $AnimationPlayer
onready var outline = $Ground/Outline
onready var figure = $Ground/Front/Figure

func _ready():
	var special = randf() > 0.7
	if special:
		figure.texture = load('res://assets/sprites/animals/b0' + str(randi() % 10) + '.png')
	else:
		figure.texture = load('res://assets/sprites/animals/a0' + str(randi() % 5) + '.png')

func _on_tap(author):
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
		
