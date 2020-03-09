extends TouchScreenButton

class_name JoyStickWheel

const ASSET_SIZE = 100
const ACCEL = 20
const THRESHOLD = 15

onready var radius = Vector2(ASSET_SIZE/2, ASSET_SIZE/2)  # radius of button
onready var boundary = get_parent().texture.get_size().x  # boundary of background
onready var orginal_position = position
var on_going_drag = -1

func _ready() -> void:
	assert(shape is CircleShape2D)
	assert(get_parent() is Sprite)


func _process(delta: float) -> void:
#	print("is up: ", is_action_pressed("up"))
#	print("is down: ", is_action_pressed("down"))
#	print("is left: ", is_action_pressed("left"))
#	print("is right: ", is_action_pressed("right"))
	if on_going_drag == -1:
		# move back button to center if there's no ongoing drag
		position += (orginal_position - position) * ACCEL * delta


func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
		# TODO simplify statement to calculate new position
		var new_position = null
		if (event.position - get_parent().global_position).length() < boundary:
			# there's touch inside boundary, remark that there's new drag and calculate new position
			new_position = event.position
			on_going_drag = event.get_index()
		elif on_going_drag == event.get_index():
			# there's on going drag outside boundary, new position will stick on boundary
			new_position = get_parent().global_position + (event.position - get_parent().global_position).normalized() * boundary

		if new_position != null:
			# update button center position if need
			global_position = new_position - radius * global_scale
	elif (event is InputEventScreenTouch and !event.is_pressed()):
		# touch is release. No more on going drag
		on_going_drag = -1

func is_action_pressed(action_name: String) -> bool:
	match action_name:
		"up":
			return (position.y - orginal_position.y) < -THRESHOLD
		"down":
			return (position.y - orginal_position.y) > THRESHOLD
		"right":
			return (position.x - orginal_position.x) > THRESHOLD
		"left":
			return (position.x - orginal_position.x) < -THRESHOLD
		_:
			return false
