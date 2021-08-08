extends Ball

const BASIC_FIGURES = [
	'animals/a00',
	'animals/a01',
	'animals/a02',
	'animals/a03',
	'animals/a04'
]
const ADVANCED_FIGURES = [
	'animals/b00',
	'animals/b01',
	'animals/b02',
	'animals/b03',
	'animals/b04',
	'animals/b05',
	'animals/b06',
	'animals/b07',
	'animals/b08',
	'animals/b09',
	'animals/b10'
]
var alien : String

func _ready():
	._ready()
	remove_from_group('in_camera')
	
	alien = BASIC_FIGURES[randi() % len(BASIC_FIGURES)]
	$Sprite/Alien.texture = load('res://assets/sprites/' + alien + '.png')

func start() -> void:
	$Sprite/AnimationPlayer.play("Wobble")

func dive() -> void:
	apply_central_impulse(Vector2.UP*200)
