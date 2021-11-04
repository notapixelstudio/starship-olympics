extends Ball
class_name Alien

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
var kind : String

func _ready():
	._ready()
	remove_from_group('in_camera')
	
	kind = BASIC_FIGURES[randi() % len(BASIC_FIGURES)]
	$Graphics/Alien.texture = load('res://assets/sprites/' + kind + '.png')

func start() -> void:
	$Graphics/AnimationPlayer.play("Wobble")

func dive() -> void:
	apply_central_impulse(Vector2.UP*300)
	
func get_texture():
	return $Graphics/Alien.texture
	
func is_rotatable():
	return false
	
func get_kind():
	return kind
	
