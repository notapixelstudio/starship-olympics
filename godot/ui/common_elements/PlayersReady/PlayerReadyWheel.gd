extends Control

const SPEED = 100
const SPEED_DECREASE = 700
var time = 0
signal player_ready
var player : Player: set = set_player
@export var debug_controls: String

var _controls: PackedStringArray

@onready var ready_label = $Ready

func _ready():
	ready_label.visible = false
	if player == null and debug_controls:
		player = Player.new()
		player.set_controls(debug_controls)
		_set_controls(debug_controls)
	
func set_player(v: Player):
	player = v
	_set_controls(player.get_controls())
	
	if not is_inside_tree():
		await self.ready
	
	$PlayerID.text = player.get_username()
	$controls.text = player.get_controls()
	$Wheel.modulate = player.get_color()
	$PlayerID.modulate = player.get_color()
	$Ship.texture = player.get_ship_image()
	
func _set_controls(v: String) -> void:
	_controls = v.split('+')
	
func _process(delta):
	var pressing := false
	for control in _controls:
		if Input.is_action_pressed(control+"_fire"):
			time += (delta*SPEED)
			pressing = true
			break
	if not pressing:
		time = max(0, time - delta*SPEED_DECREASE)
	$Wheel.material.set_shader_parameter("value", time)
	if time >= 100.0:
		set_process_input(false)
		set_process(false)
		ready_label.visible = true
		Events.player_ready.emit(player)
		player_ready.emit(player)
		modulate = Color(1.16,1.16,1.16,1)
