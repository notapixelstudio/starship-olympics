extends Node2D

var enabled

class_name MapCursor

export var player_i : int
export var cell_size : int
export var grid_position : Vector2 setget set_grid_position

var player 
onready var move_tween = $MoveTween
onready var animation_player = $Wrapper/Graphics/AnimationPlayer

onready var ship = $Wrapper/Graphics/Ship
onready var placemark = $Wrapper/Graphics/Placemark
onready var label = $Wrapper/Graphics/LabelContainer/Label
onready var winner = $Wrapper/Graphics/Ship/Winner

var winner_status = false

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

func setup(infoplayer: InfoPlayer):
	self.player = infoplayer
	
func _ready():
	enable()
	ship.texture = player.species.ship
	label.text = str(player.id)
	placemark.modulate = player.species.color
	label.modulate = player.species.color
	ship.rotation = -rotation - PI/2
	
	var winner = global.the_game.get_last_winner()
	
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

const DEADZONE = 0.1

func enable():
	enabled = true
	visible = true
	
func disable():
	enabled = false
	visible = false

func land():
	animation_player.play('Act')
	
func set_rotation_degrees(v):
	rotation_degrees = v
	$Wrapper/Graphics/LabelContainer.rotation = -rotation
	$Wrapper/Graphics/Ship.rotation = -rotation-PI/2
