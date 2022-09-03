extends Ball
class_name Alien

var dive_speed := 300.0

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

func set_dive_speed(v: float) -> void:
	dive_speed = v
	
func dive() -> void:
	apply_central_impulse(Vector2.UP*dive_speed)
	
func get_texture():
	return $Graphics/Alien.texture
	
func is_rotatable():
	return false
	
func is_glowing():
	return false
	
func get_kind():
	return kind
	
func has_kind(k):
	return self.get_kind() == k
	
func is_equivalent_to(holdable2):
	return .is_equivalent_to(holdable2) and self.has_kind(holdable2.get_kind())
	
