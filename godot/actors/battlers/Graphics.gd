extends Position2D

const TWEEN_DURATION = 0.3

onready var tween = $Tween
onready var anim = $AnimationPlayer

var battler_anim

var position_start = Vector2()

signal stop_invincible
func initialize():
	for child in get_children():
		if child.is_in_group("anim_species"):
			battler_anim = child
	
func move_forward():
	var direction = Vector2(-1.0, 0.0) if owner.party_member else Vector2(1.0, 0.0)
	tween.interpolate_property(
		self,
		'position',
		position_start,
		position_start + 0.1 * direction,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")

func return_to_start():
	tween.interpolate_property(
		self,
		'position',
		position,
		position_start,
		TWEEN_DURATION,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")

func play_death():
	yield(battler_anim.play_disappear(), "completed")

func invincible():
	yield(battler_anim.play_invincible(), "completed")
	emit_signal("stop_invincible")