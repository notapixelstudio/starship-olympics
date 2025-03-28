extends SessionPointIcon
class_name StarIcon

@onready var won_anim = $Wrapper/WonAnimationPlayer
@onready var float_anim = $Wrapper/FloatAnimationPlayer
@onready var sprite = $Wrapper/Sprite2D
@onready var label = $Wrapper/Label

var _index : int
var _just_scored := false
var _scored := false
var _perfect := false

func set_index(v:int):
	_index = v

func set_just_scored(v:bool):
	_just_scored = v
	
func _on_just_scored():
	won_anim.play("won")
	z_index = 100
	label.text = 'PERFECT!' if _perfect else ''

func set_scored(v:bool):
	_scored = v
	
func set_perfect(v:bool):
	_perfect = v
	
func _ready():
	$"%Sprite2D".play('full' if _scored else 'empty')
	$"%Sprite2D".visible = _scored
	
	if _perfect:
		sprite.modulate = Color(1.3,0,1.3,1)
	else:
		sprite.modulate = Color(1.1,1.1,1.1,1)
		
	$Wrapper/P.visible = _perfect
	
	if _just_scored:
		_on_just_scored()
	
	await get_tree().create_timer(_index*0.2).timeout
	float_anim.play('float')
