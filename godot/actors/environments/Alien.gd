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

var direction := Vector2.UP
var step := 3

func _ready():
	._ready()
	remove_from_group('in_camera')
	
	kind = BASIC_FIGURES[randi() % len(BASIC_FIGURES)]
	$Graphics/Alien.texture = load('res://assets/sprites/' + kind + '.png')

func start() -> void:
	$Graphics/AnimationPlayer.play("Wobble")

func dive() -> void:
	var strength = 200
	if direction == Vector2.UP:
		strength = 400
		
	apply_central_impulse(direction*strength)
	match step:
		0:
			direction = Vector2.UP
		1,2,3,4:
			direction = Vector2.LEFT
		5:
			direction = Vector2.UP
		6,7,8,9:
			direction = Vector2.RIGHT
	step = (step+1) % 10
	
func get_texture():
	return $Graphics/Alien.texture
	
func is_rotatable():
	return false
	
func get_kind():
	return kind
	
