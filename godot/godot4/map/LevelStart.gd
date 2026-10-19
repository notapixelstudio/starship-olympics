@tool
extends Area2D

@export var minigame : Minigame :
	set = set_minigame
	
@export_enum(&'winter') var modifiers : Array[String] :
	set = set_modifiers
	
	
signal tapped(author: Ship, strength: float)

func set_minigame(v: Minigame) -> void:
	minigame = v
	$Sprite2D.texture = minigame.icon

func get_minigame() -> Minigame:
	return minigame
	
func set_modifiers(v: Array[String]) -> void:
	modifiers = v
	if &'winter' in modifiers:
		%ModifierSprite2D.texture = preload("res://assets/sprites/weapons/ice.png")
	else:
		%ModifierSprite2D.texture = null
		
func get_modifiers() -> Array[String]:
	return modifiers
	
func _on_body_entered(body):
	if not body is Ship:
		return
		
	scale = Vector2(1.5,1.5)

func _on_body_exited(body):
	if not body is Ship:
		return
	
	scale = Vector2(1,1)
