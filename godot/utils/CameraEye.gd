extends Sprite2D

@export var active := true

func _ready():
	visible = false
	
func set_active(value):
	active = value
	if active:
		self.add_to_group('in_camera')
	else:
		self.remove_from_group('in_camera')
