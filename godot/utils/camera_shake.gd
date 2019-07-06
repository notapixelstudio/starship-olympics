# from: https://www.reddit.com/r/godot/comments/aoa1a2/godot_trauma_screenshake_code/
# https://twitter.com/_Azza292
# MIT License

extends Camera

export var decay_rate = 0.4
export var max_yaw = 0.05
export var max_pitch = 0.05
export var max_roll = 0.1
export var max_offset = 0.2

var _start_position
var _start_rotation
var _trauma


func add_trauma(amount):
	_trauma = min(_trauma + amount, 1)

func _ready():
	_start_position = translation
	_start_rotation = rotation
	_trauma = 0.0

func _process(delta):
	
	if _trauma > 0:
		_decay_trauma(delta)
		_apply_shake()
		
func _decay_trauma(delta):
	var change = decay_rate * delta
	_trauma = max(_trauma - change, 0)

func _apply_shake():
	var shake = _trauma * _trauma
	var yaw = max_yaw * shake * _get_neg_or_pos_scalar()
	var pitch = max_pitch * shake * _get_neg_or_pos_scalar()
	var roll = max_roll * shake * _get_neg_or_pos_scalar()
	var o_x = max_offset * shake * _get_neg_or_pos_scalar()
	var o_y = max_offset * shake * _get_neg_or_pos_scalar()
	var o_z = max_offset * shake * _get_neg_or_pos_scalar()
	translation = _start_position + Vector3(o_x, o_y, o_z)
	rotation = _start_rotation + Vector3(pitch, yaw, roll)

func _get_neg_or_pos_scalar():
		return rand_range(-1.0, 1.0)