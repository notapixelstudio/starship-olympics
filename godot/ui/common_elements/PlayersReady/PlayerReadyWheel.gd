extends Control

const SPEED = 100
const SPEED_DECREASE = 700
var time = 0
signal completed
var player_info : InfoPlayer setget set_player_info
export var player_str: String 

onready var ready_label = $Ready

func _ready():
	set_process(false)
	ready_label.visible = false
	if player_info == null and player_str:
		var p_info = InfoPlayer.new()
		p_info.controls = player_str
		self.player_info = p_info
	
	
func set_player_info(new_value: InfoPlayer):
	assert(new_value as InfoPlayer)
	player_info = new_value
	set_process(true)
	if not is_inside_tree():
		yield(self, "ready")
	$PlayerID.text = player_info.id
	$controls.text = player_info.controls
	$Wheel.modulate = player_info.get_color()
	$PlayerID.modulate = player_info.get_color()
	$Ship.texture = player_info.get_ship()
	
func _process(delta):
	if Input.is_action_pressed(player_info.controls+"_fire"):
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play(time/SPEED)
		time += (delta*SPEED)
	else:
		if $AudioStreamPlayer.playing:
			$AudioStreamPlayer.stop()
		time = max(0, time - delta*SPEED_DECREASE)
	$Wheel.material.set_shader_param("value", time)
	if time >= 100.0:
		set_process_input(false)
		set_process(false)
		ready_label.visible = true
		Events.emit_signal("player_ready", player_info)
		modulate = Color(1.16,1.16,1.16,1)
