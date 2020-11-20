extends Sprite

const DEADZONE = 0.2
onready var sprite = $Sprite

func _process(delta):
	if abs(sprite.position.x) < DEADZONE:
		sprite.position.x = 0
	if abs(sprite.position.y) < DEADZONE:
		sprite.position.y = 0
	sprite.modulate.a = abs(sprite.position.normalized().length())
