extends Area2D

onready var anim = $AnimationPlayer
onready var outline = $Ground/Outline

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
		
