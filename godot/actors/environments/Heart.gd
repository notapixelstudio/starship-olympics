extends Ball

func _ready():
	._ready()
	remove_from_group('in_camera')

func start() -> void:
	$Sprite/AnimationPlayer.play("Wobble")

func dive() -> void:
	apply_central_impulse(Vector2.UP*200)
