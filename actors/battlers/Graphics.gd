extends Position2D

const TWEEN_DURATION = 0.3

onready var tween = $Tween
onready var anim = $AnimationPlayer

export (PackedScene) var battler_anim

var position_start = Vector2()
func _ready():
	hide()

func initialize():
	pass

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

func play_stagger():
	battler_anim.play_stagger()

func play_death():
	yield(battler_anim.play_death(), "completed")

func appear():
	anim.play("appear")

