@tool
extends Area2D

@export var minigame : Minigame :
	set = set_minigame
	
signal tapped(author: Ship, strength: float)

func set_minigame(v: Minigame) -> void:
	minigame = v
	$Sprite2D.texture = minigame.icon

func get_minigame() -> Minigame:
	return minigame
	

func _on_body_entered(body):
	if not body is Ship:
		return
		
	scale = Vector2(1.5,1.5)

func _on_body_exited(body):
	if not body is Ship:
		return
	
	scale = Vector2(1,1)
