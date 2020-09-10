tool

extends Node2D

var enabled

export var species : Resource setget set_species
export var player_i : int
export var cell_size : int
export var grid_position : Vector2 setget set_grid_position

var player 
onready var move_tween = $MoveTween
onready var animation_player = $Wrapper/Graphics/AnimationPlayer
onready var animation_player_act = $Wrapper/Graphics/AnimationPlayerAct
onready var ship = $Wrapper/Graphics/Ship
onready var placemark = $Wrapper/Graphics/Placemark
onready var label = $Wrapper/Graphics/LabelContainer/Label

var wait = 0

func set_grid_position(value):
	grid_position = value
	
	if is_inside_tree():
		# tween to target position
		move_tween.interpolate_property(self, 'position',
			self.position, cell_size * grid_position, 0.25,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
		move_tween.start()
	else:
		position = cell_size * grid_position

func set_species(value):
	species = value
	
func _ready():
	enable()
	ship.texture = species.ship
	label.text = "P" + str(player_i+1)
	placemark.modulate = (species as Species).color
	ship.rotation = -rotation - PI/2
	$Wrapper/Graphics/LabelContainer.rotation = -rotation
	
	yield(get_tree().create_timer(wait), "timeout")
	animation_player.play('Float')
	
signal try_move
signal select
signal cancel

func set_unresponsive():
	set_process(false)
	set_process_input(false)

const controls_map = {
	"down": "S",
	"up": "N",
	"left": "W",
	"right": "E"
	}

const FIRST_DELAY = 0.25
const FOLLOW_DELAY = 0.25

var action_time = 0.0
var down
var up
var left
var right
var accept

func _process(delta):
	if action_time >= 0.0:
		action_time -= delta
		
	down = Input.is_action_just_pressed(player.controls+"_down")
	up = Input.is_action_just_pressed(player.controls+"_up")
	left = Input.is_action_just_pressed(player.controls+"_left")
	right = Input.is_action_just_pressed(player.controls+"_right")
	accept = Input.is_action_just_pressed(player.controls+"_fire")
	
	if not enabled and (down or up or left or right or accept):
		emit_signal("cancel", self)
		return
		
	for key in controls_map:
		if get(key):
			emit_signal('try_move', self, controls_map[key])
			action_time = FIRST_DELAY
	
	if accept:
		emit_signal('select', self)
	
	down = Input.is_action_pressed(player.controls+"_down") and action_time <= 0.0
	up = Input.is_action_pressed(player.controls+"_up") and action_time <= 0.0
	left = Input.is_action_pressed(player.controls+"_left") and action_time <= 0.0
	right = Input.is_action_pressed(player.controls+"_right") and action_time <= 0.0
	accept = Input.is_action_pressed(player.controls+"_fire") and action_time <= 0.0
	
	for key in controls_map:
		if get(key):
			emit_signal('try_move', self, controls_map[key])
			action_time = FOLLOW_DELAY
	
func enable():
	enabled = true
	visible = true
	
func disable():
	enabled = false
	visible = false
	
func on_sth_pressed(sth_good = true):
	if sth_good:
		animation_player.play('Act')
	else:
		animation_player.play('shake')
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'Act':
		animation_player.play('Float')
	else:
		animation_player.play('Float')
