@tool
extends Marker2D

@export var ship_texture : Texture2D: set = change_texture
const TWEEN_DURATION = 0.3

var position_start = Vector2()

signal stop_invincible
signal completed

@onready var tween = $Tween
@onready var anim = $AnimationPlayer

func change_texture(new_value):
	ship_texture = new_value
	if not is_inside_tree():
		await self.ready
	$Sprite2D.texture = ship_texture
		
func play_disappear():
	anim.play("disappear")
	await anim.animation_finished

func play_idle():
	anim.play("idle")
	await anim.animation_finished

func invincible(offset = 0):
	anim.play("invincible")
	anim.seek(offset)
	await anim.animation_finished
	emit_signal("stop_invincible")
