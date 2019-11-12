extends Position2D
tool

export var ship_texture : Texture setget change_texture
const TWEEN_DURATION = 0.3

var position_start = Vector2()

signal stop_invincible
signal completed

onready var tween = $Tween
onready var anim = $AnimationPlayer

func change_texture(new_value):
	ship_texture = new_value
	if $Sprite:
		$Sprite.texture = ship_texture
		
func play_disappear():
	anim.play("disappear")
	yield(anim, "animation_finished")

func play_idle():
	anim.play("idle")
	yield(anim, "animation_finished")

func invincible(offset = 0):
	anim.play("invincible")
	anim.seek(offset)
	yield(anim, "animation_finished")
	emit_signal("stop_invincible")
